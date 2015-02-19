/** @jsx React.DOM */

var OrderDetailIBox = React.createClass({
	render: function() {
		var chartValues  = this.props.chartValues;
		var shorts = this.props.shorts;
		return (<div className="ibox float-e-margins">
				<IBoxTitleBar>
                    <IBoxTitleText>Order Group shorter Burn Down</IBoxTitleText>
                </IBoxTitleBar>
					  <IBoxSection>
						  <DoughnutChart dataValues={chartValues}/>
					  </IBoxSection>
					  <IBoxSection>
						  {shorts} Shorts &gt;
					  </IBoxSection>
                <IBoxSection>
402/ hour
                </IBoxSection>
                <IBoxSection>
Active Runs
                </IBoxSection>
                <IBoxSection>
# [ | ]
                </IBoxSection>
                <IBoxSection>
# [ | ]


                </IBoxSection>
                <IBoxSection>
Show all complete runs &gt;

                </IBoxSection>
            </div>);

	}
});
