import React from 'react';
import { render } from 'react-dom';
import Chart from './Chart';
import { getData } from "./utils"

class ChartComponent extends React.Component {
	componentDidMount() {
		getData().then(data => {
			console.log(data);
			this.setState({ data })
		})
	}
	render() {
		if (this.state == null) {
			return <div>Loading...</div>
		}
		return (
			<Chart type="svg" data={this.state.data} />
		)
	}
}

render(
	<ChartComponent />,
	document.getElementById("root")
);
