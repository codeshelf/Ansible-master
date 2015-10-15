function Doughnut(selector, initialSegments, chartOptions) {
	var drawContext = $(selector).get(0).getContext("2d");
	this.chart = new Chart(drawContext).Doughnut(initialSegments, chartOptions);

}

Doughnut.prototype.updateDataValues = function(newSegments) {
   var segments = this.chart.segments;
   for(var i = 0; i < segments.length; i++) {
	   var segment = segments[i];
	   $.extend(segment, newSegments[i]);
   }
};

Doughnut.prototype.render = function() {
	this.chart.update();
};
