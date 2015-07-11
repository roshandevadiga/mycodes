# rubocop:disable ClassLength

module AgileCrm
  module Services
    # PatchContacts is responsible of patching all of our customers with their deal into agile crm
    class PatchContacts
      # rubocop:disable MethodLength
      def execute(limit = 0, list_of_customers = [])
        return specific_customers(list_of_customers) if list_of_customers.present?
        if limit.to_i > 0
          customers_with_limitation limit
        else
          customers_without_limitaion
        end
      end

      private

      def specific_customers(list_of_customers)
        customers_relations.valid_ones.find(list_of_customers).each do |customer|
          process_customer customer
        end
      end

      def customers_with_limitation(limit)
        customers_relations.valid_ones.limit(limit).each do |customer|
          process_customer customer
        end
        return limit #assuming count is expected as return type
      end

      def customers_without_limitaion
        selected_customers = 0
        customers_relations.valid_ones.find_in_batches(batch_size: 100) do |customers|
          selected_customers += customers.count
          customers.each do |customer|
            process_customer customer
          end
        end
        selected_customers #assuming count is expected as return type
      end

      #TODO : This can be a scope in Customer model returning a Arel (Customer.relations)
      # def customers_relations
      #   Customer.includes(customer_deposit_products: [:customer, :deposit_product, procedures: :party_procedures])
      # end

      def process_customer(customer)
        Rails.logger.info("processing Customer No. #{ customer.id } with email #{ customer.email }. \n")

        if customer.agile_crm_contact_id.present?
          update_agile_crm_contact(customer)
          update_exist_customer_deals(customer)
        else
          create_agile_crm_contact(customer)
          create_new_customer_deals(customer)
        end
      end

      def update_exist_customer_deals(customer)
        customer.customer_deposit_products.each do |customer_deposit_product|
          if customer_deposit_product.agile_crm_deal_id.present?
            if milestone_name(customer_deposit_product) == 'target_bank_funds_received'
              update_deal(customer_deposit_product)
            else
              update_amount(customer_deposit_product)
            end
          else
            create_deal(customer_deposit_product)
          end
        end
      end

      def update_amount(customer_deposit_product)
        current_agile_deal = api_client.get_deal(customer_deposit_product.agile_crm_deal_id)
        if current_agile_deal && current_agile_deal['expected_value'] != customer_deposit_product.amount
          api_client.update_deal(current_agile_deal['id'],
            name: current_agile_deal['name'],
            contact_ids: current_agile_deal['contact_ids'],
            milestone: current_agile_deal['milestone'],
            expected_value: customer_deposit_product.amount
          )
        end
      rescue StandardError => err
        Rails.logger.error(err)
      end

      def deal_attributes(customer_deposit_product)
        deposit_name = customer_deposit_product.deposit_product.decorate.customer_friendly_description_decorated
        {
          name: deposit_name,
          contact_ids: [customer_deposit_product.customer.agile_crm_contact_id],
          milestone: Milestones[milestone_name(customer_deposit_product)],
          expected_value: customer_deposit_product.amount.to_i
        }
      end

      def create_new_customer_deals(customer)
        customer.customer_deposit_products.each do |customer_deposit_product|
          create_deal(customer_deposit_product)
        end
      end

      def milestone_name(customer_deposit_product)
        return 'soft_lead' unless customer_deposit_product.confirmed.present?

        procedure = customer_deposit_product.procedures.first
        # party_procedures = procedure.party_procedures

        source_party = procedure.party_procedures.where(party_role: 'source_party')
        target_party = procedure.party_procedures.where(party_role: 'target_party')

        if target_party[:state] == 'completed'
          'target_bank_funds_received'
        else
          source_party_milestone(source_party[:state], customer_deposit_product)
        end
      end

      #TODO ; Better to delegate this to mysql would be faster, defining a scope in model
      # def valid_customer?(customer)
      #   # customer has not submitted step 1, if first_name is missing
      #   return false unless customer.first_name.present?
      #   return false if customer.status == 'terminated'

      #   values = [customer.first_name, customer.last_name, customer.email]
      #   !values.any? { |val| val =~ /test/i }
      # end

      # rubocop:disable CyclomaticComplexity, PerceivedComplexity
      def source_party_milestone(state, customer_deposit_product)
        type = customer_deposit_product.procedures.first.kind
        case state
        when 'waiting_for_customer_application'
          'pdf_downloaded'
        when 'receiving'
          receiving_state(customer_deposit_product, type)
        when 'resolving'
          'problems'
        when 'problems', 'corrections', 'bank_account', 'docs_uploading', 'welcome_package', 'entax'
          'documents_received'
        when 'money_receiving'
          type == 'ncd' ? 'welcome_pack_sent' : 'documents_received'
        when 'target_bank_info', 'funds_transfer', 'funds_transfer_info', 'completed'
          'source_bank_funds_received'
        else
          fail("Undefined milestone for #{ state } state for customer deposit product No. #{ customer_deposit_product.id }")
        end
      end

      def receiving_state(customer_deposit_product, type)
        country = customer_deposit_product.deposit_product.country
        return nil unless type == 'ncd' && country == 'AT'

        if type == 'ecd'
          'unqualified_lead'
        elsif customer_deposit_product.pdf_download_date.present?
          'pdf_downloaded'
        end
      end

      def customers
        Customer.relations.valid_ones
        #Moved to sql query, rather than rails processing
        # Customer.includes(customer_deposit_products: [:customer, :deposit_product, procedures: :party_procedures]).find_in_batches(batch_size: 10) do |batch|
        #   batch.select { |c| valid_customer?(c) }
        # end
      end

      # Not needed better to have a DB filter
      # def party_procedure(procedures, type) 
      #   procedures.detect { |procedure| procedure[:party_role] == type }
      # end
      
      def api_client
        @api_client ||= Clients::Factory.new.new_instance
      end
# API's can be moved to a separate class --------------------------------------
      def update_deal(customer_deposit_product)
        api_client.update_deal(customer_deposit_product.agile_crm_deal_id, deal_attributes(customer_deposit_product))
      rescue StandardError => err
        Rails.logger.error(err)
      end

       def update_agile_crm_contact(customer)
        api_client.update_contact(
          customer.agile_crm_contact_id,
          email: customer.email,
          first_name: customer.first_name,
          last_name: customer.last_name,
          phone: { mobile: customer.mobile_phone_number.to_s, home: customer.phone_number.to_s },
          address: { postal: customer.decorate.postal_address.to_s },
          date_of_birth: customer.date_of_birth.to_time.to_i
        )
      rescue StandardError => err
        Rails.logger.error(err)
      end

      def create_agile_crm_contact(customer)
        res = api_client.create_contact(
          email: customer.email,
          first_name: customer.first_name,
          last_name: customer.last_name,
          phone: { mobile: customer.mobile_phone_number.to_s, home: customer.phone_number.to_s },
          address: { postal: customer.decorate.postal_address.to_s },
          date_of_birth: customer.date_of_birth.to_time.to_i
        )
        customer.update_attribute(:agile_crm_contact_id, res['id']) if res
      rescue StandardError => err
        Rails.logger.error(err)
      end

      def create_deal(customer_deposit_product)
        res = api_client.create_deal(deal_attributes(customer_deposit_product))
        customer_deposit_product.update_attribute(:agile_crm_deal_id, res['id']) if res
      rescue StandardError => err
        Rails.logger.error(err)
      end
#--------------------------------------------------API's------------------------
    end
  end
end



#Customer model, defining here just the code that are moved
class Customer < ActiveRecord::base 
  STATUS = {"terminated" : "T"} #To save some space on db, single length field
  TEST_CHR = 'test'
  scope :relations, ->{
    includes(customer_deposit_products: [:customer, :deposit_product, procedures: :party_procedures])
  }

  scope :valid_ones, -> {
    where(["first_name is NOT NULL and status != ?", STATUS[:terminated]])
    .where("concat(customer.first_name,customer.last_name,customer.email) NOT LIKE ?", "%#{TEST_CHR}%")
  }
end