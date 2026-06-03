# TÜİK Forecasting Project

## 1. Project Overview

This project develops a monthly time series forecasting model using official announcement and advertisement fee data published by TÜİK (Turkish Statistical Institute). Ten quantitative forecasting methods are applied, compared using standard accuracy measures, and the superior method is selected to produce a forecast for January 2025.

---

## 2. Data Source and TÜİK Connection

Data were accessed directly from the TÜİK Data Portal using the `tuikr` R package. No manual download or data entry was performed.

| Field | Value |
|---|---|
| TÜİK Data Set Name | Official announcement and advertisement fees by month and type and the number of official announcements published by month |
| TÜİK Theme / Category | Culture and Sports (Theme 10) |
| TÜİK Table Name | Official announcement and advertisement fees by month and type and the number of official announcements published by month |
| TÜİK Dataflow ID | istab table, accessed via `statistical_tables(theme = 10)`, row 8 |
| Selected Variable | Total official announcement and advertisement fees (TL) |
| Data Frequency | Monthly |
| Time Coverage | January 2018 – December 2024 |
| Latest Available Observation | December 2024 |
| Forecast Target Period | January 2025 |
| Date of Data Access | See notebook |
| R Package Used | `tuikr` |
| Package Source | https://github.com/emraher/tuikr |

**Note on data access method:** The selected table is of type `istab` on the TÜİK portal. The `tuikr::statistical_tables()` function provides the download URL. TÜİK's server blocks plain programmatic requests (HTTP 403) but responds to browser-simulated requests (HTTP 200). The notebook uses `httr::GET()` with standard browser headers (User-Agent, Referer) to download the Excel file reproducibly within R. No manual download was performed.

---

## 3. Research Objective

This project forecasts the total monthly official announcement and advertisement fees (in Turkish Lira) collected by TÜİK. This variable is meaningful because it reflects the volume and pricing of legally mandated public announcements in Turkey, capturing both the level of official commercial and legal activity and the broader inflationary environment.

---

## 4. Use of TÜİK Data in R

The data imported through `tuikr` were used directly in R for all analysis. No manually prepared, edited, or newly created data file was used at any stage.

- **Selected variable:** Total official announcement and advertisement fees (TL) — column 2 of the raw Excel file
- **Time variable:** Year and month, reconstructed from the stacked Excel structure using `stringr` pattern matching
- **Data frequency:** Monthly (12 observations per year)
- **Latest available observation:** December 2024
- **Forecast target period:** January 2025
- **R-based adjustments:** Year labels were extracted from block headers using regex; month rows were identified by Turkish month names; the note row was removed; a proper `Date` variable and a `ts` object with `frequency = 12` were created entirely in R

---

## 5. Exploratory Time Series Analysis

- **Trend:** Strong upward trend, especially from 2022 onward
- **Seasonality:** Clear recurring pattern — November peaks, August troughs
- **Structural break:** April 2023 — internet news websites added to coverage scope
- **COVID-19 effect:** Sharp dip in April–May 2020
- **Missing values:** None
- **Outliers:** 2020 pandemic dip; 2022–2024 acceleration

---

## 6. Forecasting Methods Applied

| Method | Applicable? |
|---|---|
| Naïve Forecasting | Yes |
| Moving Average (k=3) | Yes |
| Weighted Moving Average (0.5/0.3/0.2) | Yes |
| Exponential Smoothing (alpha=0.4) | Yes |
| Trend-Adjusted ES / Holt (alpha=0.4, beta=0.2) | Yes — series has a clear trend |
| Linear Trend Projection | Yes |
| Seasonal Indices | Yes — monthly data with recurring seasonal pattern |
| Additive Decomposition | Yes |
| Multiplicative Decomposition | Yes — seasonal amplitude grows with level |
| Regression with Trend and Seasonal Dummies | Yes — monthly data with trend and seasonality |

---

## 7. Forecast Accuracy Comparison

See `outputs/tables/accuracy_comparison.csv` for the full table with Bias, MAD, MSE, MAPE, RSFE, and Tracking Signal for all methods.

---

## 8. Selection of the Superior Method

**Selected method: Regression with Trend and Seasonal Dummy Variables**

Justification:
- Lowest or near-lowest MAPE and MAD among all methods
- Explicitly models both the upward trend (via time index) and seasonal pattern (via monthly dummies)
- Tracking signal indicates no systematic bias
- Interpretable coefficients that directly quantify trend growth and seasonal deviations
- Most appropriate for a series with both strong trend and consistent seasonality

---

## 9. Final Next-Period Forecast

| Field | Value |
|---|---|
| Selected Superior Method | Regression with Trend and Seasonal Dummy Variables |
| Date of Data Access | See notebook |
| Latest Available TÜİK Observation | December 2024 |
| Forecast Target Period | January 2025 |
| Forecasted Value | See `outputs/tables/final_forecast.csv` |

---

## 10. Interpretation of Results

The January 2025 forecast reflects continued growth in official announcement fees, consistent with the strong upward trend driven by inflation and expanded coverage. January is typically a low-season month relative to November–December, and the seasonal dummy captures this. The forecast should be interpreted as a baseline projection under the assumption that current trend and seasonal patterns persist.

---

## 11. Limitations

- Structural break in April 2023 (internet news websites added to scope)
- COVID-19 shock in April–May 2020 inflates error measures
- Nonlinear acceleration after 2022 may cause underestimation by a linear trend model
- Only 84 monthly observations (7 years)
- Nominal TL values — not adjusted for inflation
- No external explanatory variables

---

## 12. Reproducibility

1. Clone the repository:
```bash
git clone https://github.com/erenyenice/tuik-forecasting-project
cd tuik-forecasting-project
```

2. Install R packages:
```r
install.packages(c("httr", "readxl", "dplyr", "stringr", "ggplot2", "forecast", "rmarkdown"))
remotes::install_github("emraher/tuikr")
```

3. Create output folders (the notebook does this automatically, but you can also run):
```r
dir.create("outputs/figures", recursive = TRUE)
dir.create("outputs/tables", recursive = TRUE)
```

4. Knit the notebook:
```r
rmarkdown::render("forecasting_project.Rmd")
```

All data are fetched live from TÜİK at knit time. No local data file is needed.

---

## 13. Repository Structure

```
tuik-forecasting-project/
├── README.md
├── forecasting_project.Rmd
├── forecasting_project.html
├── outputs/
│   ├── tables/
│   │   ├── accuracy_comparison.csv
│   │   └── final_forecast.csv
│   └── figures/
│       ├── actual_series_plot.png
│       ├── naive_forecast_plot.png
│       ├── moving_average_plot.png
│       ├── weighted_moving_average_plot.png
│       ├── exponential_smoothing_plot.png
│       ├── trend_adjusted_smoothing_plot.png
│       ├── trend_projection_plot.png
│       ├── seasonal_indices_plot.png
│       ├── additive_decomposition_plot.png
│       ├── multiplicative_decomposition_plot.png
│       ├── regression_seasonal_dummy_plot.png
│       └── superior_method_plot.png
├── R/
│   ├── data_import.R
│   ├── forecasting_methods.R
│   ├── accuracy_measures.R
│   └── plots.R
├── renv.lock
└── .gitignore
```

---

## 14. Author

- **Student Name:** Eren Yenice
- **Student Number:** 138722006
- **Course:** Forecasting Methods
