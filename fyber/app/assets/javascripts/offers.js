var Fyber = {};

(function($, App){
	App.prototype =  {
		init: function(){
			this.bindSubmit();
		},

		bindSubmit : function(){
			$('#formSubmit').off('click').on('click', function(e){
				e.preventDefault();
				$.ajax({
					url : '/offers/fetch',
					data : $('#offerForm').serialize(),
					type : 'post',
					success : function(resp){
						$('#results').html(resp);
					},
					error: function(){

					}
				})
			});
		}
	}
})(jQuery, Fyber)