/** @jsx React.DOM */

var IBoxTitleText = RClass(function() {
		return (<h5>{this.props.children}</h5>);
	});

var IBoxTitleTools = RClass(function() {
	return (
		<div className="ibox-tools dropdown">
			<a onclick="{showhide();}"> <i className="fa fa-chevron-up"></i></a>
			<a className="dropdown-toggle" href>
			<i className="fa fa-wrench"></i>
			</a>
			<a onclick="closebox()"><i className="fa fa-times"></i></a>
		</div>);
	});

var IBoxTitleBar = RClass(function() {
		return (<div className="ibox-title">
				{this.props.children}
				</div>);
	});

var IBoxSection = RClass(function() {
    return (<div className="ibox-content">
				{this.props.children}
            </div>);
	});
