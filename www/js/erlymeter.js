var statusUpdater;
var snapshotUpdater;
function start() {
    startCounter();
    new Ajax.Updater('current_state', "/perferl/perferl/startit", { parameters: Form.serialize('parametersForm'),
                                                                                   onSuccess:function() { highlight('current_state');},
                                                                                   asynchronous:true,
                                                                                   evalScripts:true
                                                                                 })
    statusUpdater = updateStatus();
    snapshotUpdater = updateSnapshot();
}

function highlight(elem){
//    new Effect.Highlight(elem, {startcolor:'#ffffff',endcolor:'#ffffaa',duration: 1});
}

function updateStatus() {
    return new PeriodicalExecuter(function() {
        new Ajax.Updater('status', "/perferl/perferl/status", {onSuccess:function(){ highlight('status')}, onComplete:function(){ finished()},asynchronous:true, evalScripts:true})
    }, 1)
}

function updateSnapshot() {
    return new PeriodicalExecuter(function() {
        new Ajax.Updater('content', "/perferl/perferl/snapshot", {onComplete:function(){ highlight('content')}})
    }, 1)
}

function finished() {
    if($('finishedCount').innerHTML != $('processCount').innerHTML) return;
    statusUpdater.stop();
    snapshotUpdater.stop();
    stopCounter();
    new Ajax.Updater('chart',"/perferl/perferl/finished", {onComplete:function(){ highlight('content')}});
}