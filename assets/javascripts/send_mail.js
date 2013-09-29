//
//  make row for mail recipients
//
//

new function(){
	var countRow = 0;

	var getRow = function(category,addr,target) { // row add 
		countRow ++;
		if (category != 'to' || category != 'to' || category != 'bcc' ) {
			catetory = 'to';
		};
		select_str = '<select name="category[recipient' + countRow + ']" >';
		select_str += '<option value="to"' + ( ( category == 'to') ? ' selected' : '' ) + '>to</option>';
		select_str += '<option value="cc"' + ( ( category == 'cc') ? ' selected' : '' ) + '>cc</option>';
		select_str += '<option value="bcc"' + ( ( category == 'bcc') ? ' selected' : '' ) + '>bcc</option>';
		select_str += '</select>';
		text_str    = '<input type="text" name="addr[recipient' + countRow + ']" value="' + addr + '" size="80" />';
		button_str  = '<input type="button" value="-" onclick="mail_dispatch_ext.delRow(' + countRow + ',\''+target+'\')" />';
		tr_str = '<p id="group' + countRow + '"><label>' + select_str + '</label>' + text_str + '<span class="button">' + button_str + '</span></p>';
		return tr_str ;
	};

	mail_dispatch_ext = {

		hideAddButton: function(target) { // delete 'add button'
				$("#add",target).remove();
		},

		showAddButton:  function(target) { // add 'add button'
				$(".button:last",target).append('<input id="add" type="button" value="+" onclick="mail_dispatch_ext.addRow(\'to\',\'\',\''+target+'\');" />');
		},

		delRow: function (num){ // delete row
			this.hideAddButton(target);
			// delete row
			$('#group'+num).remove();
			// show 'add button' at last row
			this.showAddButton(target);
		},

		addRow: function(category,addr,target){
			this.hideAddButton(target);
			// add row 
			$(target).append(getRow(category,addr,target));
			// add 'add button' at last row
			this.showAddButton(target);
		}
	}
}

