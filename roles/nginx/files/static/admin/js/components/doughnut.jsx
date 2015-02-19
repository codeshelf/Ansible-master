/** @jsx React.DOM */

var DoughnutChart = RClass(function() {
	return (<canvas style={{'height': 400, 'width': 350}}></canvas>);
	},
	{
		componentDidMount: function() {
			var chart = new Doughnut(this.getDOMNode(), this.props.dataValues, {
							percentageInnerCutout: 80,
							animateRotate : false
				});
			chart.render();
			this.setState({chart: chart});
			console.log("doughnut mounted");
		},
		componentWillUnmount: function() {
			this.state.chart.destroy();
		},
		componentDidUpdate: function(prevProps, prevState) {
			var chart = this.state.chart;
			chart.updateDataValues(this.props.dataValues);
			chart.render();
		}

	});
