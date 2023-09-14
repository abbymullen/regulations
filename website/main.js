import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";

const texts = await d3.csv("all-texts.csv");
const matches = await d3.csv("regulation-matches.csv");

const getReg = (id) => {
  let filtered = texts.filter((x) => x.id === id);
  if (filtered.length === 1) {
    return filtered[0].text;
  } else {
    return "N/A";
  }
};

const isMatch = (x) => {
  return x !== "" ? "✅" : "";
};

const truncate = (s) => {
  let max = 40;
  if (s.length <= max) {
    return s;
  } else {
    return s.slice(0, max) + " …";
  }
};

const tblRow = (d) => {
  return `
  <td data-regulation=usn-1802 data-id=${d.borrower_section}>${truncate(getReg(d.borrower_section))}</td>
  <td class="centered" data-regulation=usn-1800 data-id=${d.usn_1800}>${isMatch(d.usn_1800)}</td>
  <td class="centered" data-regulation=usn-1798 data-id=${d.usn_1798}>${isMatch(d.usn_1798)}</td>
  <td class="centered" data-regulation=rn-1790 data-id=${d.rn_1790}>${isMatch(d.rn_1790)}</td>
  <td class="centered" data-regulation=usn-1775 data-id=${d.usn_1775}>${isMatch(d.usn_1775)}</td>`;
};

d3.select("#matches-table")
  .selectAll("tr")
  .data(matches)
  .enter()
  .append("tr")
  .html((d) => tblRow(d));

d3.selectAll("tr").on("click", function () {
  d3.select(this)
    .selectAll("td")
    .each(function (d) {
      let reg = d3.select(this).attr("data-regulation");
      let id = d3.select(this).attr("data-id");
      d3.select("#" + reg).text(getReg(id));
    });
});
