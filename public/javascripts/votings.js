$(document).ready(function(){
    $("a.showhide").click(function(){
        $(this).parent().parent().parent().find('.collapsible').toggle('fast');
        $(this).find('.showhide').toggle();
    })
    $("a.addNewNomination").click(function(){
        // stubbed TODO
    })
    $("a.vote").click(function(){
        
    })
    $("a.second").click(function(){
        
    })
    $("a.accept").click(function(){
        
    })
    $("a.reject").click(function(){
        
    })
})