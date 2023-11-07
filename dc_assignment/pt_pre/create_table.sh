TOP_LIST="s386 s1238 s9234 s15850 s35932"
# 100MHz
echo "\\begin{tabular}{| Design | Area | Power | WNS | TNS | Cell Count | Num of violating paths |}" > table.tex
echo "\\caption{100MHz DC logic synthesis results.}" >> table.tex
echo "    \\hline" >> table.tex

for top in $TOP_LIST; do
	report_dir=designs/$top/reports
	dc_report_dir=../dc_synth/$report_dir
	source <(gawk -f find_tns.awk $report_dir/pt_qor.rpt)
	power="$(sed -n 'x;$p' $dc_report_dir/synth_power.rpt | gawk -- '{ print $(NF-1) }')"
	echo "    ${top}.v & $area & $power & $wns & $tns & $cell_count & $num_violating \\\\" >> table.tex
	echo "    \\hline" >> table.tex
done
echo "\\end{tabular}" >> table.tex

# 500MHz
echo "\\begin{tabular}{| Design | Area | Power | WNS | TNS | Cell Count | Num of violating paths |}" >> table.tex
echo "\\caption{500MHz DC logic synthesis results.}" >> table.tex
echo "    \\hline" >> table.tex

for top in $TOP_LIST; do
	report_dir=designs_500MHz/$top/reports
	dc_report_dir=../dc_synth/$report_dir
	source <(gawk -f find_tns.awk $report_dir/pt_qor.rpt)
	power="$(sed -n 'x;$p' $dc_report_dir/synth_power.rpt | gawk -- '{ print $(NF-1) }')"
	echo "    ${top}.v & $area & $power & $wns & $tns & $cell_count & $num_violating \\\\" >> table.tex
	echo "    \\hline" >> table.tex
done
echo "\\end{tabular}" >> table.tex
echo "" >> table.tex
