$(document).ready(function(){
    $("a.showhide").click(function(){
        $(this).parent().parent().parent().find('.collapsible').toggle('fast');
        $(this).find('.showhide').toggle();
    })
    $("a.addNewNomination").click(function(){
        // stubbed TODO
    })
})