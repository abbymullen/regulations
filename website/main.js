import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";

const texts = await d3.csv("all-texts.csv");
const matches = await d3.csv("regulation-matches.csv");

const getReg = (id) => {
  return texts.filter((x) => x.id === id)[0].text;
};

const isMatch = (x) => {
  return x !== "" ? "✅" : "";
};

const tblRow = (d) => {
  return `<td>${getReg(d.borrower_section)}</td><td class="centered" data-id=${d.usn_1800}>${isMatch(
    d.usn_1800
  )}</td><td class="centered"  data-id=${d.rn_1790}>${isMatch(d.rn_1790)}</td><td class="centered"  data-id=${
    d.usn_1775
  }>${isMatch(d.usn_1775)}</td>`;
};

d3.select("#testcontainer").append("p").text("this is the text");

d3.select("#matches-table")
  .selectAll("tr")
  .data(matches)
  .enter()
  .append("tr")
  .html((d) => tblRow(d));

d3.selectAll("td").on("click", function () {
  let id = d3.select(this).attr("data-id");
  d3.select("#original").text(getReg(id));
});
