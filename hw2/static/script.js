$(document).ready(function() {
    $('#search-form').submit(function(event) {
        event.preventDefault();  // Prevent default form submission
        let keyword = $('#keyword').val();
        $.ajax({
            url: '/search',
            method: 'GET',  // or 'POST' based on your backend setup
            data: { keyword: keyword },
            success: function(response) {
                console.log("Success")
            }
        });
    });
});
