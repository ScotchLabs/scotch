$(document).ready(function(){
    $("a.showhide").click(function(){
        $(this).parent().parent().parent().find('.collapsible').toggle('fast');
        $(this).find('.showhide').toggle();
    })
    $("a.addNewNomination").click(function(){
        // open colorbox
    })
    $("a.newRace").click(function(){
        // open colorbox
    })
    $("a.vote").click(function(){
        // post to update_nomination_path
        // update nomination link (with response?)
    })
    $("a.second").click(function(){
        // post to update_nomination_path
        // update nomination link (with response?)
    })
    $("a.accept").click(function(){
        // post to update_nomination_path
        // update nomination link (with response?)
    })
    $("a.reject").click(function(){
        // post to update_nomination_path
        // update nomination link (with response?)
    })
})