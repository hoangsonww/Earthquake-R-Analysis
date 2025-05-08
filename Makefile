.PHONY: all clean report

R_SCRIPT      := earthquake_viz_complete.R
RMD_REPORT    := earthquake_report.Rmd
HTML_REPORT   := earthquake_report.html

all: report

report: $(HTML_REPORT)

$(HTML_REPORT): $(RMD_REPORT)
	Rscript -e "rmarkdown::render('$<', output_file = '$@')"

run-script:
	Rscript $(R_SCRIPT)

clean:
	rm -f *.html *.png *.Rproj.user
