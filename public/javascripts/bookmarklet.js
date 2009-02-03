//get selected text

var URL_BASE = 'http://tagal.us';

var search_val = getSelText();

if (search_val != '') {


		window.location.href= URL_BASE + '/tag/' + escape(search_val);

} else {
	
	alert ('You have to select something for Tagalus to define first!');
	
}

//from http://www.codetoad.com/javascript_get_selected_text.asp
function getSelText()
{
	var userSelection;
	if (window.getSelection) {
		userSelection = window.getSelection();
	}
	else if (document.selection) { // should come last; Opera!
		userSelection = document.selection.createRange();
	}
	return userSelection;

}