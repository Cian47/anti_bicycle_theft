$(document).ready(function(){
	$('newBikeForm')
		.formValidation({
			framework: 'bootstrap'
			icon: {
                valid: 'glyphicon glyphicon-ok',
                invalid: 'glyphicon glyphicon-remove',
                validating: 'glyphicon glyphicon-refresh'
            },
            fields: {
                nickname: {
                    row: '.col-xs-4',
                    validators: {
                        notEmpty: {
                            message: 'A Nickname for you Bike is required	'
                        }
                    }
		})
}