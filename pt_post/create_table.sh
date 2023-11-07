TOP_LIST="s386 s1238 s9234 s15850 s35932"
echo "\\documentclass{article}" > table.tex
echo "\\usepackage[left=0.75in, right=0.75in, top=0.75in, bottom=0.75in]{geometry}" >> table.tex
echo "\\usepackage{multirow}" >> table.tex

echo "" >> table.tex
echo "\\title{IC Compiler Assignment}" >> table.tex
echo "\\author{Nicholas Sica}" >> table.tex
echo "\\date{March 22, 2023}" >> table.tex
echo "" >> table.tex

echo "\\begin{document}" >> table.tex
echo "\\maketitle" >> table.tex
echo "" >> table.tex

echo "\\begin{table}" >> table.tex
echo "\\centering" >> table.tex
echo "\\caption{Pre-layout and Post-layout simulation results.}" >> table.tex
echo "\\begin{tabular}{ |c|c|c|c|c|c|c|c|c|c|c|c|c| }" >> table.tex
echo "    \\hline" >> table.tex
echo "    \\multirow{2}{*}{Design} & \\multicolumn{5}{|c|}{Pre-Layout Results} & \\multicolumn{6}{|c|}{Post-Layout Results} \\\\" >> table.tex
echo "    \\cline{2-12}" >> table.tex
echo "    & Area & Power & WNS & TNS & Cell Count & Area & Power & WNS & TNS & Cell Count & DRC \\\\" >> table.tex
echo "    \\hline" >> table.tex

for top in $TOP_LIST; do
	post_report_dir=reports/$top
	icc_report_dir=../icc_pnr/$post_report_dir
	pre_report_dir=../pt_pre/reports/$top
	dc_report_dir=../dc_synth/$post_report_dir

	source <(gawk -f get_values.awk $pre_report_dir/pt_qor.rpt)
	power="$(sed -n 'x;$p' $dc_report_dir/synth_power.rpt | gawk -- '{ print $(NF-1) }')"
	output="${top}.v & $area & $power & $wns & $tns & $cell_count "
	source <(gawk -f get_values.awk $post_report_dir/qor.rpt)
	power="$(sed -n 'x;$p' $icc_report_dir/extracted_power.rpt | gawk -- '{ print $(NF-1) }')"
	echo "    "$output"& $area & $power & $wns & $tns & $cell_count & $drc \\\\" >> table.tex
	echo "    \\hline" >> table.tex

	source <(gawk -f get_values.awk $icc_report_dir/extracted_clock_tree.rpt)
	clock_sinks=$clock_sinks" $sinks & $buffs & $skew \\\\\n"
done
echo "\\end{tabular}" >> table.tex
echo "\\end{table}" >> table.tex
echo "" >> table.tex

echo "\\begin{table}" >> table.tex
echo "\\centering" >> table.tex
echo "\\caption{Clock information.}" >> table.tex
echo "\\begin{tabular}{ |c|c|c|c| }" >> table.tex
echo "    \\hline" >> table.tex
echo "    Design & \\# Clock Sinks & \\# Clock Buffers & Global Clock Skew \\\\" >> table.tex
echo "    \\hline" >> table.tex

for top in $TOP_LIST; do
	post_report_dir=reports/$top
	icc_report_dir=../icc_pnr/$post_report_dir

	source <(gawk -f get_clk_info.awk $icc_report_dir/extracted_clock_tree.rpt)
	echo "    ${top}.v & $sinks & $buffs & $skew \\\\" >> table.tex
done
echo "\\end{tabular}" >> table.tex
echo "\\end{table}" >> table.tex
echo "" >> table.tex
echo "\\end{document}" >> table.tex
