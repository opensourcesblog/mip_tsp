let fileNo = "25_1";

var width = 500,
    height = 500,
    centered;


// Set svg width & height
var svg = d3.select('#chart').append('svg')
    .attr('width', width)
    .attr('height', height);

var g = svg.append('g');
g.attr("transform", "translate(10, 10)");

// define scales
let scaleX = d3.scaleLinear().range([5,width-10*2]);
let scaleY = d3.scaleLinear().range([5,height-10*2]);

/**
 * Render the problem
 */
function render(data,solData) {
    if (solData) {
        for (let cIdx in solData["next"]) {
            let toIdx = solData["next"][cIdx]["to"];
            data["city"][cIdx]["to"] = toIdx;
            data["city"][cIdx]["toX"] = data["city"][toIdx].x;
            data["city"][cIdx]["toY"] = data["city"][toIdx].y;
        }
    }

    scaleX.domain(d3.extent(data["city"], d=>{return d.x;}));
    scaleY.domain(d3.extent(data["city"], d=>{return d.y;}));

    let xSpan = scaleX.domain()[1]-scaleX.domain()[0];
    let ySpan = scaleY.domain()[1]-scaleY.domain()[0];

    if (xSpan > ySpan) {
        let newYMin = scaleY.domain()[0]-(xSpan - ySpan)/2;
        let newYMax = scaleY.domain()[1]+(xSpan - ySpan)/2;
        scaleY.domain([newYMin,newYMax]);
    } else {
        let newXMin = scaleX.domain()[0]-(ySpan - xSpan)/2;
        let newXMax = scaleX.domain()[1]+(ySpan - xSpan)/2;
        scaleX.domain([newXMin,newXMax]);
    }

    let cityCircles = g.selectAll(".city-cirlces").data(data["city"]).enter();
    cityCircles.append("circle")
        .attr("class", "city-cirlces")
        .attr("cx", d => {return scaleX(d.x);})
        .attr("cy", d => {return scaleY(d.y);})
        .attr("r", 2);

    let lines = g.selectAll(".from-to-line").data(data["city"]).enter();
        lines.append("line")
            .attr("class","from-to-line")
            .attr("x1", d => {return scaleX(d.x);})
            .attr("y1", d => {return scaleY(d.y);})
            .attr("x2", d => {return scaleX(d.toX);})
            .attr("y2", d => {return scaleY(d.toY);})
            .attr("stroke", "black");
}

function parsePro(text) {
    let lines = text.split("\n");
    let data = {};
    data["city"] = [];
    for (let lIdx in lines) {
        lines[lIdx] = lines[lIdx].trim();
        let [x,y] = lines[lIdx].split(" ").map(Number);
        data["city"].push({
            x,y  
        });
    }
    return data;
}


function parseSol(text) {
    let lines = text.split("\n");
    let data = {};
    data["next"] = [];
    for (let lIdx in lines) {
        lines[lIdx] = lines[lIdx].trim();
        if (lIdx == 0) {
            [data["obj"],data["opt"]] = lines[lIdx].split(" ").map(Number); 
        } else if (lIdx == 1) {
            let tos = lines[lIdx].split(" ").map(Number);
            for (let to of tos) {
                data["next"].push({to:to-1});
            }
        }
    }
    return data;
}


d3.request("./data/tsp_"+fileNo)
    .mimeType("text/plain")
    .response(d=> {return parsePro(d.responseText);})
    .get(data => {
        d3.request("./sol/tsp_"+fileNo)
            .mimeType("text/plain")
            .response(d=> {return parseSol(d.responseText);})
            .get(solData => {
                render(data, solData);
        })  
    })