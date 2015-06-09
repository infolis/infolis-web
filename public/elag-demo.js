var INFOLIS_BASE_URI = "http://localhost:3000/api";

var learnSeed;
var learnPdfUris = [];
var applyPdfUris = [];
var learnTextUris = [];
var applyTextUris = [];
var patternUris = [];
var newDatasetTerms = [];

function hackySleep(sec) {
  for (var i = 0; i < sec * 1000000 ; i++) {
  }
}

function _pollExecution(executionUri, execution, onFinished) {
  if (execution.status === 'FINISHED' || execution.status === 'FAILED') {
    return onFinished(execution);
  }
  var poll = new XMLHttpRequest();
  poll.open("GET", executionUri);
  poll.setRequestHeader('Accept', 'application/json');
  poll.onreadystatechange = function() {
  if (poll.readyState === 4) {
    execution = JSON.parse(poll.responseText);
  }
  }
  poll.send();
  setTimeout(function() {
    console.log("Polling " + executionUri);
  _pollExecution(executionUri, execution, onFinished);
  }, 1000);
}

function pollExecution(executionUri, onFinished) {
  _pollExecution(executionUri, {}, onFinished);
}

function uploadFiles(id, arr) {
  var uploaded = 0;
  var div = $(id);
  var input = $("input", div).get(0);
  var pre = $("pre", div);

  var nrFiles = input.files.length;
  for (var i = 0; i < nrFiles ; i++) {
    (function(i){
      var file = input.files[i];
      var form = new FormData();
      var req = new XMLHttpRequest();

      form.append("file", file)
      req.onreadystatechange = function() {
        if(req.readyState === 4 && req.status === 201) {
          console.log("Uploaded");
          var uri = req.getResponseHeader('Location')
          arr.push(uri);
          if (++uploaded == nrFiles) {
            div.addClass("done");
            pre.text(JSON.stringify(arr, null, 2));
          }
        }
      };
      req.open("POST", INFOLIS_BASE_URI + "/upload")
      req.send(form);
    }(i));
  }
}

function convertToText(id, source, target) {
  var form = new FormData();
  var req = new XMLHttpRequest();
  var div = $(id);
  var input = $("input", div).get(0);
  var pre = $("pre", div);
  var span = $("span", div);

  for (var i = 0; i < source.length ; i++) {
    form.append("inputFiles", source[i]);
  }
  form.append("algorithm", "io.github.infolis.algorithm.TextExtractorAlgorithm");
  req.onreadystatechange = function() {
    if (req.readyState === 4) {
      var executionUri = req.getResponseHeader('Location');
      span.append("<a href=" + executionUri +">" + executionUri+"</a>")
      pollExecution(executionUri, function(execution) {
    execution.outputFiles.forEach(function(textUri) {
      target.push(textUri);
    });
    pre.text(JSON.stringify(target, null, 2));
    div.addClass("done");
    });
    }
  }
  req.open("POST", INFOLIS_BASE_URI + "/execute");
  req.send(form);
}

function learn(id, target) {
  var form = new FormData();
  var req = new XMLHttpRequest();
  var div = $(id);
  var input = $("input", div).get(0);
  var pre = $("pre", div);
  var span = $("span", div);

  form.append("algorithm", "io.github.infolis.algorithm.FrequencyBasedBootstrapping");
  for (var i = 0; i < learnTextUris.length ; i++) {
    form.append("inputFiles", learnTextUris[i]);
  }
  form.append("terms", learnSeed);
  form.append("threshold", 0);
  form.append("maxIterations", 3);

  req.onreadystatechange = function() {
    if (req.readyState !== 4)
      return;
    var executionUri = req.getResponseHeader('Location');
      span.append("<a href=" + executionUri +">" + executionUri+"</a>")
  pollExecution(executionUri, function(execution) {
    for (var i = 0; i < execution.pattern.length; i++) {
      target.push(execution.pattern[i]);
    }
    console.log(target);
    pre.text(JSON.stringify(target, null, 2));
    div.addClass("done");
  });
  },
  req.open("POST", INFOLIS_BASE_URI + "/execute");
  req.send(form);
}

function applyPatterns(id) {
  var form = new FormData();
  var req = new XMLHttpRequest();
  var div = $(id);
  var pre = $("pre", div);
  var span = $("span", div);
  form.append("algorithm", "io.github.infolis.algorithm.PatternApplier");
  for (var i = 0; i < applyTextUris.length ; i++) {
    form.append("inputFiles", applyTextUris[i]);
  }
  for (var i = 0; i < patternUris.length ; i++) {
    form.append("pattern", patternUris[i]);
  }
  req.onreadystatechange = function() {
	if (req.readyState !== 4) return;
	var executionUri = req.getResponseHeader('Location');
	span.append("<a href=" + executionUri +">" + executionUri+"</a>")
	pollExecution(executionUri, function(execution) {
	  console.log(execution.studyContexts);
	  for (var i = 0; i < execution.studyContexts.length ; i++) {
	  	(function(i) {
		  var contextUri = execution.studyContexts[i];
		  var contextReq = new XMLHttpRequest();
		  contextReq.open("GET", contextUri);
		  contextReq.setRequestHeader('Accept', 'application/json')
		  contextReq.onreadystatechange = function() {
			  if (contextReq.readyState !== 4) {
				  return;
			  }
			  var context = JSON.parse(contextReq.responseText);
			  console.log(context);
			  pre.append(context.file + "\t" + context.term + "\n");
		  };
		  contextReq.send();
		}(i));
	  }
	  div.addClass("done");
	});
  }
  req.open("POST", INFOLIS_BASE_URI + "/execute");
  req.send(form);
}

$("#upload-learn-pdf button").on('click', function() {
  uploadFiles("#upload-learn-pdf", learnPdfUris); 
});

$("#convert-learn-pdf button").on('click', function() {
  convertToText("#convert-learn-pdf", learnPdfUris, learnTextUris);
});

$("#learning button").on('click', function() {
  learnSeed = $("#learning input").val();
  learn("#learning", patternUris);
});

$("#upload-apply-pdf button").on('click', function() {
  uploadFiles("#upload-apply-pdf", applyPdfUris); 
});

$("#convert-apply-pdf button").on('click', function() {
  convertToText("#convert-apply-pdf", applyPdfUris, applyTextUris);
});

$("#apply-patterns button").on('click', function() {
  applyPatterns("#apply-patterns");
});
