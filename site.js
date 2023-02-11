const PUBLIC_KEY = "obk3lno5ptmj";

const TEXT_HEADER = new Headers();
TEXT_HEADER.append("Content-Type", "text/plain");
TEXT_HEADER.append("x-ebirdapitoken", PUBLIC_KEY);

const JSON_HEADER = new Headers();
JSON_HEADER.append("x-ebirdapitoken", PUBLIC_KEY);

const TODAY = moment();
const YEAR_START = moment().startOf("year");

window.addEventListener(
  "load",
  () => {
    const taxonomy = document.getElementById("taxonomy");
    taxonomy.addEventListener("click", downloadTaxonomy, false);

    const observations = document.getElementById("observations");
    observations.innerHTML = `Download Ebird Observations Data in United States`;
    // `(${YEAR_START.format("l")} to ${TODAY.format("l")})`;

    observations.addEventListener("click", downloadObservations, false);

    const subregions = document.getElementById("subregions");
    subregions.addEventListener("click", downloadSubRegions, false);

    const boundary = document.getElementById("boundary");
    boundary.addEventListener("click", downloadBoundary, false);
  },
  false
);

function downloadTaxonomy() {
  fetch(`https://api.ebird.org/v2/ref/taxonomy/ebird?fmt=csv`, {
    headers: TEXT_HEADER,
  })
    .then((res) => res.text())
    .then((data) => download("ebird-taxonomy.csv", data));
}

// function downloadObservations() {
//   let startDate = YEAR_START,
//     endDate = TODAY,
//     duration = moment.duration(endDate.diff(startDate));

//   alert("This may take a few minutes...and may miss multiple days of data");
//   let days = duration.asDays();
//   let urls = [];
//   let fetches = [];
//   let allData = [];

//   for (let i = 0; i <= days; i++) {
//     let year = startDate.year(),
//       month = startDate.month() + 1,
//       day = startDate.date();
//     urls.push(
//       `https://api.ebird.org/v2/data/obs/US/historic/${year}/${month}/${day}`
//     );
//     startDate.add(1, "day");
//   }

//   urls.forEach((url) => {
//     fetches.push(
//       fetch(url, {
//         headers: JSON_HEADER,
//       })
//         .then((res) => {
//           if (res.ok) {
//             return res.json();
//           } else {
//             return Promise.resolve([]);
//           }
//         })
//         .then((data) => {
//           allData.push(...data);
//         })
//     );
//   });

//   Promise.all(fetches).then(() => {
//     const { Parser } = window["json2csv"];
//     const json2csvParser = new Parser();
//     const csv = json2csvParser.parse(allData);
//     download("ebird-obs-current-year.csv", csv);
//   });
// }

function downloadObservations() {
  window.open(
    "https://select-top-4.github.io/ebird-data-exploration/current_year_obs.csv",
    "_blank"
  );
}

function downloadSubRegions() {
  fetch(`https://api.ebird.org/v2/ref/region/list/subnational1/US?fmt=csv`, {
    headers: TEXT_HEADER,
  })
    .then((res) => res.text())
    .then((data) => download("us-sub-regions.csv", data));
}

function downloadBoundary() {
  alert("This may take a few seconds...");

  let urls = [];
  let fetches = [];
  let allData = [];

  fetch(`https://api.ebird.org/v2/ref/region/list/subnational1/US`, {
    headers: JSON_HEADER,
  })
    .then((res) => res.json())
    .then((subregions) => {
      subregions.forEach((subregion) => {
        urls.push(`https://api.ebird.org/v2/ref/region/info/${subregion.code}`);
      });

      urls.forEach((url) => {
        fetches.push(
          fetch(url, {
            headers: JSON_HEADER,
          })
            .then((res) => {
              if (res.ok) {
                return res.json();
              } else {
                return Promise.resolve([]);
              }
            })
            .then((data) => {
              let boundary = {
                region_code: url.slice(-5),
                region: data.result,
                ...data.bounds,
              };
              allData.push(boundary);
            })
        );
      });
    })
    .then(() => {
      Promise.all(fetches).then(() => {
        const { Parser } = window["json2csv"];
        const json2csvParser = new Parser();
        const csv = json2csvParser.parse(allData);
        download("us-subregion-boundaries.csv", csv);
      });
    });
}

function download(filename, text) {
  let element = document.createElement("a");
  element.setAttribute(
    "href",
    "data:text/plain;charset=utf-8," + encodeURIComponent(text)
  );
  element.setAttribute("download", filename);

  element.style.display = "none";
  document.body.appendChild(element);
  element.click();
  document.body.removeChild(element);
}

function downloadJSON(filename, exportObj) {
  let element = document.createElement("a");
  element.setAttribute(
    "href",
    "data:text/json;charset=utf-8," +
      encodeURIComponent(JSON.stringify(exportObj))
  );
  element.setAttribute("download", filename);

  element.style.display = "none";
  document.body.appendChild(element);
  element.click();
  document.body.removeChild(element);
}
