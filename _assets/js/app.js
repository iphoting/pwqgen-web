function fallbackMessage(action) {
  var actionMsg = '';
  var actionKey = (action === 'cut' ? 'X' : 'C');
  if (/iPhone|iPad/i.test(navigator.userAgent)) {
      actionMsg = 'No support :(';
  }
  else if (/Mac/i.test(navigator.userAgent)) {
      actionMsg = 'Press ⌘-' + actionKey + ' to ' + action;
  }
  else {
      actionMsg = 'Press Ctrl-' + actionKey + ' to ' + action;
  }
  return actionMsg;
}

var clipboard = new Clipboard('#copy-button');

clipboard.on('success', function(e) {
  e.clearSelection();
  $('#copy-button').tooltip({ title: 'Copied!' }).tooltip('show');
});

clipboard.on('error', function(e) {
  $('#copy-button').tooltip({ title: fallbackMessage(e.action) }).tooltip('show');
});
