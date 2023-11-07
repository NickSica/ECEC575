/******************************************************************************/
/* TSMC N28 P&R technology file                                               */
/******************************************************************************/
/* DESIGN RULE DOCUMENT: T-N28-CL-DR-001 V1.4_1                               */
/* DESIGN RULE DOCUMENT: T-N28-CL-DR-002 V1.2_1                               */
/* P&R TECHNOLOGY FILE VERSION: T-N28-CL-PR-002-S1 V1.2_1a1_pre20130913       */
/*                                                                            */
/* Note :                                                                     */
/*       1. Please use ICC F-2011.09-SP2 or later version                     */
/*       2. Please use TLUPlus to get the accurate RC values.                 */
/*       3. ICC G-2012.06-SP5 or later version for implant support            */
/* Revision Histroy :                                                         */
/*       1. 20101117 MxLPC rules                                              */
/*       2. 20101122 new VIAy.S.3 & My.S.8 rules                              */
/*       3. 20110209 add DFM v01 VMA/HOOK/CAP rule                            */
/*       4. 20110318 apply Synopsys VIA Reliability new syntax                */
/*       5. 20110318 refine values in VMA/HOOK/CAP syntax                     */
/*       6. 20110401 New ContactCode apply VIAx.EN.14 & VIAx.EN.15            */
/*       7. 20110429 Remove VIAx.S.6 & VIAx.S.7                               */
/*       8. 20110627 Add rectangular Power VIA PGVIAx_RECT                    */
/*       9. 20110627 Bridge rule support                                      */
/*      10. 20110627 New modeling for WMJ rule                                */
/*      11. 20110627 Update Hook rule for M1/M2                               */
/*      12. 20111212 New support EFP.Mx.EN.1R, VIAx.R.10R, Mx.S.37R           */
/*      13. 20120131 Reorganize DesignRule section                            */
/*      14. 20120305 DFM via revision                                         */
/*                   *FBD20,*FBD30,*PBDB,*PBDU,*PBDE,*FBS25,*PBSB,*PBSU       */
/*      15. 20120305 RV 2x2 is only allowed in plymide process                */
/*                   Please refer to v1.2 design rule RV.W.1                  */
/*                   Set RV default size as 3um x 3um in this TF              */
/*                   If RV 2x2 is required, please let it unmarked,           */
/*                   and let RV 3x3 marked                                    */
/*      16. 20121003 Enhanced M1.EN.4, remove "fatWireViaCornerKeepoutDistTbl"*/
/*      17. 20130604 Add implant layer VT*                                    */
/*      18. 20130828 VIAu.R enhancement for ICC 2013                          */
/*      19. 20130905 Turn off Metal bridge rule EFP.M1/Mx.S.5~7               */
/******************************************************************************/

Technology	{
		name				= "TSMC N28 SP10M7X2ZUTRDL TCBN28"
		date				= "Sep 13 2013"
		dielectric			= 3.45e-05
		unitTimeName			= "ns"
		timePrecision			= 1000
		unitLengthName			= "micron"
		lengthPrecision			= 1000
		gridResolution			= 5
		unitVoltageName			= "v"
		voltagePrecision		= 100000
		unitCurrentName			= "mA"
		currentPrecision		= 100
		unitPowerName			= "mw"
		powerPrecision			= 1000
		unitResistanceName		= "ohm"
		resistancePrecision		= 10000000
		unitCapacitanceName		= "pf"
		capacitancePrecision		= 10000000
		unitInductanceName		= "nh"
		inductancePrecision		= 100
		minBaselineTemperature		= 25
		nomBaselineTemperature		= 25
		maxBaselineTemperature		= 25
		fatWireExtensionMode		= 1
		minEdgeMode			= 1
		minAreaMode			= 1
		maxStackLevelMode		= 2
}

Color		14 {
		name				= "14"
		rgbDefined			= 1
		redIntensity			= 0
		greenIntensity			= 255
		blueIntensity			= 190
}

Color		18 {
		name				= "18"
		rgbDefined			= 1
		redIntensity			= 90
		greenIntensity			= 0
		blueIntensity			= 190
}

Color		19 {
		name				= "19"
		rgbDefined			= 1
		redIntensity			= 90
		greenIntensity			= 0
		blueIntensity			= 255
}

Color		27 {
		name				= "27"
		rgbDefined			= 1
		redIntensity			= 90
		greenIntensity			= 175
		blueIntensity			= 255
}

Color		28 {
		name				= "28"
		rgbDefined			= 1
		redIntensity			= 90
		greenIntensity			= 255
		blueIntensity			= 0
}

Color		34 {
		name				= "34"
		rgbDefined			= 1
		redIntensity			= 180
		greenIntensity			= 0
		blueIntensity			= 190
}

Color		43 {
		name				= "43"
		rgbDefined			= 1
		redIntensity			= 180
		greenIntensity			= 175
		blueIntensity			= 255
}

Color		49 {
		name				= "49"
		rgbDefined			= 1
		redIntensity			= 255
		greenIntensity			= 0
		blueIntensity			= 100
}

Color		58 {
		name				= "58"
		rgbDefined			= 1
		redIntensity			= 255
		greenIntensity			= 175
		blueIntensity			= 190
}

Color		59 {
		name				= "59"
		rgbDefined			= 1
		redIntensity			= 255
		greenIntensity			= 175
		blueIntensity			= 255
}

Tile		"gaunit" {
		width				= 0.42
		height				= 0.9
}

Tile		"unit" {
		width				= 0.14
		height				= 0.9
}

Layer		"NW" {
		layerNumber			= 3
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "magenta"
		lineStyle			= "dash"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"OD" {
		layerNumber			= 6
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "19"
		lineStyle			= "solid"
		pattern				= "enter"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"VTL_N" {
		layerNumber			= 12
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"VTL_P" {
		layerNumber			= 13
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"PO" {
		layerNumber			= 17
		maskName			= "poly"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "49"
		lineStyle			= "solid"
		pattern				= "solid"
		pitch				= 0
		defaultWidth			= 0.03
		minWidth			= 0.03
		minSpacing			= 0.08
}

Layer		"PP" {
		layerNumber			= 25
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "14"
		lineStyle			= "dash"
		pattern				= "slash"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"NP" {
		layerNumber			= 26
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "34"
		lineStyle			= "dash"
		pattern				= "slash"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"CO" {
		layerNumber			= 30
		maskName			= "polyCont"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "27"
		lineStyle			= "solid"
		pattern				= "solid"
		pitch				= 0
		defaultWidth			= 0.04
		minWidth			= 0.04
		minSpacing			= 0.07
}

Layer		"M1" {
		layerNumber			= 31
		maskName			= "metal1"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "cyan"
		lineStyle			= "solid"
		pattern				= "dot"
		pitch				= 0.14
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 6
		fatTblThreshold			= (0,0.101,0.181,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.0115
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 2
		minAreaEdgeThresholdTbl		= (0.13,0.2)
		minAreaFillMinLengthTbl		= (0.13,0.2)
		minAreaFillMinWidthTbl		= (0.05,0.05)
		specialMinAreaTbl		= (0.038,0.014)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.06
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1MinSpacing	= 0.07
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.12
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M2" {
		layerNumber			= 32
		maskName			= "metal2"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0.1
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 7
		fatTblThreshold			= (0,0.091,0.131,0.161,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.08,0.08,0.08,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.014
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 1
		minAreaEdgeThresholdTbl		= (0.13)
		specialMinAreaTbl		= (0.044)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.07
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine1NeighborEndToEndThreshold	= 0.065
		endOfLine1NeighborEndToEndThreshold2	= 0.065
		endOfLine1NeighborEndToEndParallelWidth	= -0.02
		endOfLine1NeighborEndToEndMinSpacing	= 0.08
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1WireMinThreshold	= 0.07
		endOfLine2NeighborMod1MinSpacing	= 0.08
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M3" {
		layerNumber			= 33
		maskName			= "metal3"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "red"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0.1
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 7
		fatTblThreshold			= (0,0.091,0.131,0.161,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.08,0.08,0.08,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.017
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 1
		minAreaEdgeThresholdTbl		= (0.13)
		specialMinAreaTbl		= (0.044)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.07
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine1NeighborEndToEndThreshold	= 0.065
		endOfLine1NeighborEndToEndThreshold2	= 0.065
		endOfLine1NeighborEndToEndParallelWidth	= -0.02
		endOfLine1NeighborEndToEndMinSpacing	= 0.08
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1WireMinThreshold	= 0.07
		endOfLine2NeighborMod1MinSpacing	= 0.08
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M4" {
		layerNumber			= 34
		maskName			= "metal4"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "green"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0.1
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 7
		fatTblThreshold			= (0,0.091,0.131,0.161,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.08,0.08,0.08,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.017
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 1
		minAreaEdgeThresholdTbl		= (0.13)
		specialMinAreaTbl		= (0.044)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.07
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine1NeighborEndToEndThreshold	= 0.065
		endOfLine1NeighborEndToEndThreshold2	= 0.065
		endOfLine1NeighborEndToEndParallelWidth	= -0.02
		endOfLine1NeighborEndToEndMinSpacing	= 0.08
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1WireMinThreshold	= 0.07
		endOfLine2NeighborMod1MinSpacing	= 0.08
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M5" {
		layerNumber			= 35
		maskName			= "metal5"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "magenta"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0.1
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 7
		fatTblThreshold			= (0,0.091,0.131,0.161,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.08,0.08,0.08,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.017
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 1
		minAreaEdgeThresholdTbl		= (0.13)
		specialMinAreaTbl		= (0.044)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.07
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine1NeighborEndToEndThreshold	= 0.065
		endOfLine1NeighborEndToEndThreshold2	= 0.065
		endOfLine1NeighborEndToEndParallelWidth	= -0.02
		endOfLine1NeighborEndToEndMinSpacing	= 0.08
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1WireMinThreshold	= 0.07
		endOfLine2NeighborMod1MinSpacing	= 0.08
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M6" {
		layerNumber			= 36
		maskName			= "metal6"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "orange"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0.1
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 7
		fatTblThreshold			= (0,0.091,0.131,0.161,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.08,0.08,0.08,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.017
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 1
		minAreaEdgeThresholdTbl		= (0.13)
		specialMinAreaTbl		= (0.044)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.07
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine1NeighborEndToEndThreshold	= 0.065
		endOfLine1NeighborEndToEndThreshold2	= 0.065
		endOfLine1NeighborEndToEndParallelWidth	= -0.02
		endOfLine1NeighborEndToEndMinSpacing	= 0.08
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1WireMinThreshold	= 0.07
		endOfLine2NeighborMod1MinSpacing	= 0.08
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M7" {
		layerNumber			= 37
		maskName			= "metal7"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "blue"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0.1
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 7
		fatTblThreshold			= (0,0.091,0.131,0.161,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.08,0.08,0.08,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.017
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 1
		minAreaEdgeThresholdTbl		= (0.13)
		specialMinAreaTbl		= (0.044)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.07
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine1NeighborEndToEndThreshold	= 0.065
		endOfLine1NeighborEndToEndThreshold2	= 0.065
		endOfLine1NeighborEndToEndParallelWidth	= -0.02
		endOfLine1NeighborEndToEndMinSpacing	= 0.08
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1WireMinThreshold	= 0.07
		endOfLine2NeighborMod1MinSpacing	= 0.08
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M8" {
		layerNumber			= 38
		maskName			= "metal8"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "purple"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0.1
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.05
		maxWidth			= 4.5
		unitMinThickness		= 0.09
		unitNomThickness		= 0.09
		unitMaxThickness		= 0.09
		fatTblDimension			= 7
		fatTblThreshold			= (0,0.091,0.131,0.161,0.471,0.631,1.501)
		fatTblParallelLength		= (0,0.225,0.225,0.225,0.475,0.635,1.505)
		fatTblSpacing			= (0.05,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.06,0.06,0.08,0.1,0.13,0.15,0.5,
						   0.08,0.08,0.08,0.1,0.13,0.15,0.5,
						   0.1,0.1,0.1,0.1,0.13,0.15,0.5,
						   0.13,0.13,0.13,0.13,0.13,0.15,0.5,
						   0.15,0.15,0.15,0.15,0.15,0.15,0.5,
						   0.5,0.5,0.5,0.5,0.5,0.5,0.5)
		minArea				= 0.017
		minEnclosedArea			= 0.2
		maxNumMinEdge			= 1
		minEdgeLength			= 0.05
		minEdgeLength2			= 0.155
		minEdgeLength3			= 0.07
		specialMinAreaTblSize		= 1
		minAreaEdgeThresholdTbl		= (0.13)
		specialMinAreaTbl		= (0.044)
		endOfLine1NeighborThreshold	= 0.065
		endOfLine1NeighborMinSpacing	= 0.07
		endOfLine1NeighborCornerKeepoutWidth	= 0.025
		endOfLine1NeighborEndToEndThreshold	= 0.065
		endOfLine1NeighborEndToEndThreshold2	= 0.065
		endOfLine1NeighborEndToEndParallelWidth	= -0.02
		endOfLine1NeighborEndToEndMinSpacing	= 0.08
		endOfLine2NeighborMod1Threshold	= 0.065
		endOfLine2NeighborMod1WireMinThreshold	= 0.07
		endOfLine2NeighborMod1MinSpacing	= 0.08
		endOfLine2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLine2NeighborMod1SideKeepoutLength	= 0.07
		endOfLine2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLine3NeighborThreshold	= 0.055
		endOfLine3NeighborMinSpacing	= 0.115
		endOfLine3NeighborSideMinSpacing	= 0.06
		endOfLine3NeighborSideKeepoutLength	= 0.12
		convexMinEdgeLength		= 0.05
		convexConcaveMinEdgeLength	= 0.065
}

Layer		"M9" {
		layerNumber			= 39
		maskName			= "metal9"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "white"
		lineStyle			= "dot"
		pattern				= "backSlash"
		pitch				= 0.8
		defaultWidth			= 0.4
		minWidth			= 0.4
		minSpacing			= 0.4
		maxWidth			= 12
		unitMinThickness		= 0.85
		unitNomThickness		= 0.85
		unitMaxThickness		= 0.85
		fatTblDimension			= 3
		fatTblThreshold			= (0,1.501,4.501)
		fatTblParallelLength		= (0,1.505,4.505)
		fatTblSpacing			= (0.4,0.5,1.5,
						   0.5,0.5,1.5,
						   1.5,1.5,1.5)
		minArea				= 0.565
		minEnclosedArea			= 0.565
}

Layer		"M10" {
		layerNumber			= 40
		maskName			= "metal10"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "59"
		lineStyle			= "dot"
		pattern				= "backSlash"
		pitch				= 0.8
		defaultWidth			= 0.4
		minWidth			= 0.4
		minSpacing			= 0.4
		maxWidth			= 12
		unitMinThickness		= 0.85
		unitNomThickness		= 0.85
		unitMaxThickness		= 0.85
		fatTblDimension			= 3
		fatTblThreshold			= (0,1.501,4.501)
		fatTblParallelLength		= (0,1.505,4.505)
		fatTblSpacing			= (0.4,0.5,1.5,
						   0.5,0.5,1.5,
						   1.5,1.5,1.5)
		minArea				= 0.565
		minEnclosedArea			= 0.565
}

Layer		"VIA1" {
		layerNumber			= 51
		maskName			= "via1"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "43"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.08
		minSpacingCornerKeepoutWidth	= 0.039
		cornerMinSpacing		= 0.07
		maxStackLevel			= 4
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 7
		minCutsTbl			= (1,Vrect,-1.000,0.181,-0.999999,-1.000,
						   2,Vrect,-1.000,0.441,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,1.805,
						   2,Vrect,0.441,-1.000,-0.999999,-1.000,
						   1,Vrect,1.001,-1.000,-0.999999,4.155,
						   1,Vrect,1.501,-1.000,-0.999999,10.155)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.08
		enclosedCutToNeighborMinSpacing	= 0.08
		cutTblSize			= 2
		cutNameTbl			= (Vsq,Vrect)
		cutWidthTbl			= (0.05,0.05)
		cutHeightTbl			= (0.05,0.13)
}

Layer		"VIA2" {
		layerNumber			= 52
		maskName			= "via2"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.08
		minSpacingCornerKeepoutWidth	= 0.039
		cornerMinSpacing		= 0.07
		maxStackLevel			= 4
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 7
		minCutsTbl			= (1,Vrect,-1.000,0.181,-0.999999,-1.000,
						   2,Vrect,-1.000,0.441,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,1.805,
						   2,Vrect,0.441,-1.000,-0.999999,-1.000,
						   1,Vrect,1.001,-1.000,-0.999999,4.155,
						   1,Vrect,1.501,-1.000,-0.999999,10.155)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.08
		enclosedCutToNeighborMinSpacing	= 0.08
		cutTblSize			= 2
		cutNameTbl			= (Vsq,Vrect)
		cutWidthTbl			= (0.05,0.05)
		cutHeightTbl			= (0.05,0.13)
}

Layer		"VIA3" {
		layerNumber			= 53
		maskName			= "via3"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "red"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.08
		minSpacingCornerKeepoutWidth	= 0.039
		cornerMinSpacing		= 0.07
		maxStackLevel			= 4
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 7
		minCutsTbl			= (1,Vrect,-1.000,0.181,-0.999999,-1.000,
						   2,Vrect,-1.000,0.441,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,1.805,
						   2,Vrect,0.441,-1.000,-0.999999,-1.000,
						   1,Vrect,1.001,-1.000,-0.999999,4.155,
						   1,Vrect,1.501,-1.000,-0.999999,10.155)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.08
		enclosedCutToNeighborMinSpacing	= 0.08
		cutTblSize			= 2
		cutNameTbl			= (Vsq,Vrect)
		cutWidthTbl			= (0.05,0.05)
		cutHeightTbl			= (0.05,0.13)
}

Layer		"VIA4" {
		layerNumber			= 54
		maskName			= "via4"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "green"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.08
		minSpacingCornerKeepoutWidth	= 0.039
		cornerMinSpacing		= 0.07
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 7
		minCutsTbl			= (1,Vrect,-1.000,0.181,-0.999999,-1.000,
						   2,Vrect,-1.000,0.441,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,1.805,
						   2,Vrect,0.441,-1.000,-0.999999,-1.000,
						   1,Vrect,1.001,-1.000,-0.999999,4.155,
						   1,Vrect,1.501,-1.000,-0.999999,10.155)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.08
		enclosedCutToNeighborMinSpacing	= 0.08
		cutTblSize			= 2
		cutNameTbl			= (Vsq,Vrect)
		cutWidthTbl			= (0.05,0.05)
		cutHeightTbl			= (0.05,0.13)
}

Layer		"VIA5" {
		layerNumber			= 55
		maskName			= "via5"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "magenta"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.08
		minSpacingCornerKeepoutWidth	= 0.039
		cornerMinSpacing		= 0.07
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 7
		minCutsTbl			= (1,Vrect,-1.000,0.181,-0.999999,-1.000,
						   2,Vrect,-1.000,0.441,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,1.805,
						   2,Vrect,0.441,-1.000,-0.999999,-1.000,
						   1,Vrect,1.001,-1.000,-0.999999,4.155,
						   1,Vrect,1.501,-1.000,-0.999999,10.155)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.08
		enclosedCutToNeighborMinSpacing	= 0.08
		cutTblSize			= 2
		cutNameTbl			= (Vsq,Vrect)
		cutWidthTbl			= (0.05,0.05)
		cutHeightTbl			= (0.05,0.13)
}

Layer		"VIA6" {
		layerNumber			= 56
		maskName			= "via6"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "orange"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.08
		minSpacingCornerKeepoutWidth	= 0.039
		cornerMinSpacing		= 0.07
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 7
		minCutsTbl			= (1,Vrect,-1.000,0.181,-0.999999,-1.000,
						   2,Vrect,-1.000,0.441,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,1.805,
						   2,Vrect,0.441,-1.000,-0.999999,-1.000,
						   1,Vrect,1.001,-1.000,-0.999999,4.155,
						   1,Vrect,1.501,-1.000,-0.999999,10.155)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.08
		enclosedCutToNeighborMinSpacing	= 0.08
		cutTblSize			= 2
		cutNameTbl			= (Vsq,Vrect)
		cutWidthTbl			= (0.05,0.05)
		cutHeightTbl			= (0.05,0.13)
}

Layer		"VIA7" {
		layerNumber			= 57
		maskName			= "via7"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "blue"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 0.05
		minWidth			= 0.05
		minSpacing			= 0.08
		minSpacingCornerKeepoutWidth	= 0.039
		cornerMinSpacing		= 0.07
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 7
		minCutsTbl			= (1,Vrect,-1.000,0.181,-0.999999,-1.000,
						   2,Vrect,-1.000,0.441,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,-1.000,
						   1,Vrect,0.181,-1.000,-0.999999,1.805,
						   2,Vrect,0.441,-1.000,-0.999999,-1.000,
						   1,Vrect,1.001,-1.000,-0.999999,4.155,
						   1,Vrect,1.501,-1.000,-0.999999,10.155)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.08
		enclosedCutToNeighborMinSpacing	= 0.08
		cutTblSize			= 2
		cutNameTbl			= (Vsq,Vrect)
		cutWidthTbl			= (0.05,0.05)
		cutHeightTbl			= (0.05,0.13)
}

Layer		"VIA8" {
		layerNumber			= 58
		maskName			= "via8"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "purple"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0.36
		minWidth			= 0.36
		minSpacing			= 0.34
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 3
		minCutsTbl			= (2,Vzsq,-1.000,1.801,-0.999999,-1.000,
						   2,Vzsq,1.801,-1.000,-0.999999,-1.000,
						   2,Vzsq,3.001,-1.000,-0.999999,5.005)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.56
		enclosedCutToNeighborMinSpacing	= 0.54
		cutTblSize			= 1
		cutNameTbl			= (Vzsq)
		cutWidthTbl			= (0.36)
		cutHeightTbl			= (0.36)
}

Layer		"VIA9" {
		layerNumber			= 59
		maskName			= "via9"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "white"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0.36
		minWidth			= 0.36
		minSpacing			= 0.34
		fatTblExtensionCheckCrossingCut	= 1
		minCutsTblSize			= 3
		minCutsTbl			= (2,Vzsq,-1.000,1.801,-0.999999,-1.000,
						   2,Vzsq,1.801,-1.000,-0.999999,-1.000,
						   2,Vzsq,3.001,-1.000,-0.999999,5.005)
		enclosedCutNumNeighbor		= 3
		enclosedCutNeighborRange	= 0.56
		enclosedCutToNeighborMinSpacing	= 0.54
		cutTblSize			= 1
		cutNameTbl			= (Vzsq)
		cutWidthTbl			= (0.36)
		cutHeightTbl			= (0.36)
}

Layer		"VTH_N" {
		layerNumber			= 67
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"VTH_P" {
		layerNumber			= 68
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"AP" {
		layerNumber			= 74
		maskName			= "metal11"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pattern				= "slash"
		pitch				= 4.5
		defaultWidth			= 2
		minWidth			= 2
		minSpacing			= 2
		maxWidth			= 35
		unitMinThickness		= 2.8
		unitNomThickness		= 2.8
		unitMaxThickness		= 2.8
}

Layer		"CB" {
		layerNumber			= 76
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "18"
		lineStyle			= "solid"
		pattern				= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"RV" {
		layerNumber			= 85
		maskName			= "via10"
		isDefaultLayer			= 1
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "59"
		lineStyle			= "solid"
		pattern				= "rectangleX"
		pitch				= 0
		defaultWidth			= 3
		minWidth			= 3
		minSpacing			= 2
}

Layer		"CB2" {
		layerNumber			= 86
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "18"
		lineStyle			= "solid"
		pattern				= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"VTUH_N" {
		layerNumber			= 93
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"VTUH_P" {
		layerNumber			= 94
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"SDI" {
		layerNumber			= 122
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "58"
		lineStyle			= "dot"
		pattern				= "wave"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT_AP" {
		layerNumber			= 126
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "49"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT1" {
		layerNumber			= 131
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT2" {
		layerNumber			= 132
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "red"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT3" {
		layerNumber			= 133
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "green"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT4" {
		layerNumber			= 134
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "magenta"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT5" {
		layerNumber			= 135
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "orange"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT6" {
		layerNumber			= 136
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "blue"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT7" {
		layerNumber			= 137
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "purple"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT8" {
		layerNumber			= 138
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "white"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT9" {
		layerNumber			= 139
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "cyan"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"TEXT10" {
		layerNumber			= 140
		maskName			= ""
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pattern				= "blank"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0
		minSpacing			= 0
}

Layer		"VTUL_N" {
		layerNumber			= 151
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

Layer		"VTUL_P" {
		layerNumber			= 152
		maskName			= "implant"
		visible				= 1
		selectable			= 1
		blink				= 0
		color				= "yellow"
		lineStyle			= "solid"
		pitch				= 0
		defaultWidth			= 0
		minWidth			= 0.27
		minSpacing			= 0.27
}

ContactCode	"CONT1" {
		contactCodeNumber		= 1
		cutLayer			= "CO"
		lowerLayer			= "PO"
		upperLayer			= "M1"
		isDefaultContact		= 1
		cutWidth			= 0.04
		cutHeight			= 0.04
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.07
}

ContactCode	"VIA12_1cut" {
		contactCodeNumber		= 2
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_1cut_V" {
		contactCodeNumber		= 3
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_1cut_AS" {
		contactCodeNumber		= 4
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_LONG_H" {
		contactCodeNumber		= 5
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_LONG_V" {
		contactCodeNumber		= 6
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.13
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.04
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_LONG_HH" {
		contactCodeNumber		= 7
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_FBD20" {
		contactCodeNumber		= 8
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_FBD30" {
		contactCodeNumber		= 9
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_1cut_H_3S" {
		contactCodeNumber		= 10
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isFatContact			= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA12_PBDB" {
		contactCodeNumber		= 11
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_PBDU" {
		contactCodeNumber		= 12
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_1cut" {
		contactCodeNumber		= 13
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_1cut_V" {
		contactCodeNumber		= 14
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_1cut_AS" {
		contactCodeNumber		= 15
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_LONG_H" {
		contactCodeNumber		= 16
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_LONG_V" {
		contactCodeNumber		= 17
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.13
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.04
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_LONG_HH" {
		contactCodeNumber		= 18
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_PBDE" {
		contactCodeNumber		= 19
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_FBS25" {
		contactCodeNumber		= 20
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_1cut_H_3S" {
		contactCodeNumber		= 21
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isFatContact			= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA12_PBSB" {
		contactCodeNumber		= 22
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_PBSU" {
		contactCodeNumber		= 23
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_1cut" {
		contactCodeNumber		= 24
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_1cut_AS" {
		contactCodeNumber		= 25
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_LONG_H" {
		contactCodeNumber		= 26
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_LONG_V" {
		contactCodeNumber		= 27
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.13
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.04
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_LONG_HH" {
		contactCodeNumber		= 28
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_1cut_H_3S" {
		contactCodeNumber		= 29
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isFatContact			= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA45_1cut" {
		contactCodeNumber		= 30
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_1cut_AS" {
		contactCodeNumber		= 31
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_LONG_H" {
		contactCodeNumber		= 32
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_LONG_V" {
		contactCodeNumber		= 33
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.13
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.04
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_LONG_HH" {
		contactCodeNumber		= 34
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_1cut_H_3S" {
		contactCodeNumber		= 35
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isFatContact			= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA56_1cut" {
		contactCodeNumber		= 36
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_1cut_AS" {
		contactCodeNumber		= 37
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_LONG_H" {
		contactCodeNumber		= 38
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_LONG_V" {
		contactCodeNumber		= 39
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.13
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.04
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_LONG_HH" {
		contactCodeNumber		= 40
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_1cut_H_3S" {
		contactCodeNumber		= 41
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isFatContact			= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA67_1cut" {
		contactCodeNumber		= 42
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_1cut_AS" {
		contactCodeNumber		= 43
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_LONG_H" {
		contactCodeNumber		= 44
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_LONG_V" {
		contactCodeNumber		= 45
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.13
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.04
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_LONG_HH" {
		contactCodeNumber		= 46
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_1cut_H_3S" {
		contactCodeNumber		= 47
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isFatContact			= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA78_1cut" {
		contactCodeNumber		= 48
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_1cut_AS" {
		contactCodeNumber		= 49
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_LONG_H" {
		contactCodeNumber		= 50
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_LONG_V" {
		contactCodeNumber		= 51
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.13
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.04
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_LONG_HH" {
		contactCodeNumber		= 52
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_1cut_H_3S" {
		contactCodeNumber		= 53
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isFatContact			= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA89_1cut" {
		contactCodeNumber		= 54
		cutLayer			= "VIA8"
		lowerLayer			= "M8"
		upperLayer			= "M9"
		isDefaultContact		= 1
		cutWidth			= 0.36
		cutHeight			= 0.36
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.08
		lowerLayerEncWidth		= 0.08
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.34
}

ContactCode	"VIA89_1cut_H_3S" {
		contactCodeNumber		= 55
		cutLayer			= "VIA8"
		lowerLayer			= "M8"
		upperLayer			= "M9"
		isFatContact			= 1
		cutWidth			= 0.36
		cutHeight			= 0.36
		upperLayerEncWidth		= 0.08
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.08
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.54
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA910_1cut" {
		contactCodeNumber		= 56
		cutLayer			= "VIA9"
		lowerLayer			= "M9"
		upperLayer			= "M10"
		isDefaultContact		= 1
		cutWidth			= 0.36
		cutHeight			= 0.36
		upperLayerEncWidth		= 0.08
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.08
		minCutSpacing			= 0.34
}

ContactCode	"VIA910_1cut_H_3S" {
		contactCodeNumber		= 57
		cutLayer			= "VIA9"
		lowerLayer			= "M9"
		upperLayer			= "M10"
		isFatContact			= 1
		cutWidth			= 0.36
		cutHeight			= 0.36
		upperLayerEncWidth		= 0.08
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.08
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.54
		maxNumRowsNonTurning		= 3
}

ContactCode	"VIA10AP_1cut" {
		contactCodeNumber		= 58
		cutLayer			= "RV"
		lowerLayer			= "M10"
		upperLayer			= "AP"
		isDefaultContact		= 1
		cutWidth			= 3
		cutHeight			= 3
		upperLayerEncWidth		= 0.5
		upperLayerEncHeight		= 0.5
		lowerLayerEncWidth		= 0.5
		lowerLayerEncHeight		= 0.5
		minCutSpacing			= 2
}

ContactCode	"VIA23_FBD20" {
		contactCodeNumber		= 59
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_FBD30" {
		contactCodeNumber		= 60
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_PBDB" {
		contactCodeNumber		= 61
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_PBDU" {
		contactCodeNumber		= 62
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_PBDE" {
		contactCodeNumber		= 63
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_FBS25" {
		contactCodeNumber		= 64
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_PBSB" {
		contactCodeNumber		= 65
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_PBSU" {
		contactCodeNumber		= 66
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_FBD20" {
		contactCodeNumber		= 67
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_FBD30" {
		contactCodeNumber		= 68
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_PBDB" {
		contactCodeNumber		= 69
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_PBDU" {
		contactCodeNumber		= 70
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_PBDE" {
		contactCodeNumber		= 71
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_FBS25" {
		contactCodeNumber		= 72
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_PBSB" {
		contactCodeNumber		= 73
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_PBSU" {
		contactCodeNumber		= 74
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_FBD20" {
		contactCodeNumber		= 75
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_FBD30" {
		contactCodeNumber		= 76
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_PBDB" {
		contactCodeNumber		= 77
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_PBDU" {
		contactCodeNumber		= 78
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_PBDE" {
		contactCodeNumber		= 79
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_FBS25" {
		contactCodeNumber		= 80
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_PBSB" {
		contactCodeNumber		= 81
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_PBSU" {
		contactCodeNumber		= 82
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_FBD20" {
		contactCodeNumber		= 83
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_FBD30" {
		contactCodeNumber		= 84
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_PBDB" {
		contactCodeNumber		= 85
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_PBDU" {
		contactCodeNumber		= 86
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_PBDE" {
		contactCodeNumber		= 87
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_FBS25" {
		contactCodeNumber		= 88
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_PBSB" {
		contactCodeNumber		= 89
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_PBSU" {
		contactCodeNumber		= 90
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_FBD20" {
		contactCodeNumber		= 91
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_FBD30" {
		contactCodeNumber		= 92
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_PBDB" {
		contactCodeNumber		= 93
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_PBDU" {
		contactCodeNumber		= 94
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_PBDE" {
		contactCodeNumber		= 95
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_FBS25" {
		contactCodeNumber		= 96
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_PBSB" {
		contactCodeNumber		= 97
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_PBSU" {
		contactCodeNumber		= 98
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_FBD20" {
		contactCodeNumber		= 99
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_FBD30" {
		contactCodeNumber		= 100
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_1cut_V" {
		contactCodeNumber		= 101
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_1cut_V" {
		contactCodeNumber		= 102
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_1cut_V" {
		contactCodeNumber		= 103
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_1cut_V" {
		contactCodeNumber		= 104
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_1cut_V" {
		contactCodeNumber		= 105
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA89_1cut_V" {
		contactCodeNumber		= 106
		cutLayer			= "VIA8"
		lowerLayer			= "M8"
		upperLayer			= "M9"
		cutWidth			= 0.36
		cutHeight			= 0.36
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.08
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.08
		minCutSpacing			= 0.34
}

ContactCode	"VIA910_1cut_V" {
		contactCodeNumber		= 107
		cutLayer			= "VIA9"
		lowerLayer			= "M9"
		upperLayer			= "M10"
		cutWidth			= 0.36
		cutHeight			= 0.36
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.08
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.08
		minCutSpacing			= 0.34
}

ContactCode	"VIA78_PBDB" {
		contactCodeNumber		= 108
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.02
		lowerLayerEncHeight		= 0.02
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_PBDU" {
		contactCodeNumber		= 109
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.02
		upperLayerEncHeight		= 0.02
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_PBDE" {
		contactCodeNumber		= 110
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_1cut_EN1415" {
		contactCodeNumber		= 111
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_1cut_EN1415" {
		contactCodeNumber		= 112
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_1cut_EN1415" {
		contactCodeNumber		= 113
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_1cut_EN1415" {
		contactCodeNumber		= 114
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_1cut_EN1415" {
		contactCodeNumber		= 115
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_1cut_EN1415" {
		contactCodeNumber		= 116
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.01
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_1cut_EN1415" {
		contactCodeNumber		= 117
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isDefaultContact		= 1
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"PGVIA12_RECT" {
		contactCodeNumber		= 118
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"PGVIA23_RECT" {
		contactCodeNumber		= 119
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"PGVIA34_RECT" {
		contactCodeNumber		= 120
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"PGVIA45_RECT" {
		contactCodeNumber		= 121
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"PGVIA56_RECT" {
		contactCodeNumber		= 122
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"PGVIA67_RECT" {
		contactCodeNumber		= 123
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"PGVIA78_RECT" {
		contactCodeNumber		= 124
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		isDefaultContact		= 1
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_FBS25" {
		contactCodeNumber		= 125
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.025
		lowerLayerEncWidth		= 0.025
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_PBSB" {
		contactCodeNumber		= 126
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.025
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_PBSU" {
		contactCodeNumber		= 127
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.025
		upperLayerEncHeight		= 0.01
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_FBD" {
		contactCodeNumber		= 141
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_FBD" {
		contactCodeNumber		= 142
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_FBD" {
		contactCodeNumber		= 143
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_FBD" {
		contactCodeNumber		= 144
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_FBD" {
		contactCodeNumber		= 145
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_FBD" {
		contactCodeNumber		= 146
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_FBD" {
		contactCodeNumber		= 147
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_FBS" {
		contactCodeNumber		= 151
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_FBS" {
		contactCodeNumber		= 152
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_FBS" {
		contactCodeNumber		= 153
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_FBS" {
		contactCodeNumber		= 154
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_FBS" {
		contactCodeNumber		= 155
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_FBS" {
		contactCodeNumber		= 156
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_FBS" {
		contactCodeNumber		= 157
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_PBD" {
		contactCodeNumber		= 161
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_PBD" {
		contactCodeNumber		= 162
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_PBD" {
		contactCodeNumber		= 163
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_PBD" {
		contactCodeNumber		= 164
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_PBD" {
		contactCodeNumber		= 165
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_PBD" {
		contactCodeNumber		= 166
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_PBD" {
		contactCodeNumber		= 167
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_PBS" {
		contactCodeNumber		= 171
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_PBS" {
		contactCodeNumber		= 172
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_PBS" {
		contactCodeNumber		= 173
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_PBS" {
		contactCodeNumber		= 174
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_PBS" {
		contactCodeNumber		= 175
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_PBS" {
		contactCodeNumber		= 176
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_PBS" {
		contactCodeNumber		= 177
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.03
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.03
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_2cut_P1" {
		contactCodeNumber		= 181
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_2cut_P1" {
		contactCodeNumber		= 182
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_2cut_P1" {
		contactCodeNumber		= 183
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_2cut_P1" {
		contactCodeNumber		= 184
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_2cut_P1" {
		contactCodeNumber		= 185
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_2cut_P1" {
		contactCodeNumber		= 186
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_2cut_P1" {
		contactCodeNumber		= 187
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.01
		upperLayerEncHeight		= 0.03
		lowerLayerEncWidth		= 0.04
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_2cut_P2_BLC" {
		contactCodeNumber		= 191
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.155
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_2cut_P2_BLC" {
		contactCodeNumber		= 192
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.155
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_2cut_P2_BLC" {
		contactCodeNumber		= 193
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.155
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_2cut_P2_BLC" {
		contactCodeNumber		= 194
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.155
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_2cut_P2_BLC" {
		contactCodeNumber		= 195
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.155
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_2cut_P2_BLC" {
		contactCodeNumber		= 196
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.155
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_2cut_P2_BLC" {
		contactCodeNumber		= 197
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.155
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_2cut_P3" {
		contactCodeNumber		= 201
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_2cut_P3" {
		contactCodeNumber		= 202
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_2cut_P3" {
		contactCodeNumber		= 203
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_2cut_P3" {
		contactCodeNumber		= 204
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_2cut_P3" {
		contactCodeNumber		= 205
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_2cut_P3" {
		contactCodeNumber		= 206
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_2cut_P3" {
		contactCodeNumber		= 207
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.13
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.04
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0.01
		lowerLayerEncHeight		= 0.03
		minCutSpacing			= 0.08
}

ContactCode	"VIA12_1cut_FAT_V" {
		contactCodeNumber		= 211
		cutLayer			= "VIA1"
		lowerLayer			= "M1"
		upperLayer			= "M2"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.05
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.05
		minCutSpacing			= 0.08
}

ContactCode	"VIA23_1cut_FAT_V" {
		contactCodeNumber		= 212
		cutLayer			= "VIA2"
		lowerLayer			= "M2"
		upperLayer			= "M3"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.05
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.05
		minCutSpacing			= 0.08
}

ContactCode	"VIA34_1cut_FAT_C" {
		contactCodeNumber		= 213
		cutLayer			= "VIA3"
		lowerLayer			= "M3"
		upperLayer			= "M4"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.05
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.05
		minCutSpacing			= 0.08
}

ContactCode	"VIA45_1cut_FAT_C" {
		contactCodeNumber		= 214
		cutLayer			= "VIA4"
		lowerLayer			= "M4"
		upperLayer			= "M5"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.05
		lowerLayerEncWidth		= 0.05
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA56_1cut_FAT_C" {
		contactCodeNumber		= 215
		cutLayer			= "VIA5"
		lowerLayer			= "M5"
		upperLayer			= "M6"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.05
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.05
		minCutSpacing			= 0.08
}

ContactCode	"VIA67_1cut_FAT_C" {
		contactCodeNumber		= 216
		cutLayer			= "VIA6"
		lowerLayer			= "M6"
		upperLayer			= "M7"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0
		upperLayerEncHeight		= 0.05
		lowerLayerEncWidth		= 0.05
		lowerLayerEncHeight		= 0
		minCutSpacing			= 0.08
}

ContactCode	"VIA78_1cut_FAT_C" {
		contactCodeNumber		= 217
		cutLayer			= "VIA7"
		lowerLayer			= "M7"
		upperLayer			= "M8"
		cutWidth			= 0.05
		cutHeight			= 0.05
		upperLayerEncWidth		= 0.05
		upperLayerEncHeight		= 0
		lowerLayerEncWidth		= 0
		lowerLayerEncHeight		= 0.05
		minCutSpacing			= 0.08
}

DesignRule	{
		layer1				= "via1Blockage"
		layer2				= "VIA1"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via2Blockage"
		layer2				= "VIA2"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via3Blockage"
		layer2				= "VIA3"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via4Blockage"
		layer2				= "VIA4"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via5Blockage"
		layer2				= "VIA5"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via6Blockage"
		layer2				= "VIA6"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via7Blockage"
		layer2				= "VIA7"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via8Blockage"
		layer2				= "VIA8"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "via9Blockage"
		layer2				= "VIA9"
		minSpacing			= 0
}

DesignRule	{
		layer1				= "M2"
		layer2				= "VIA1"
		minSpacing			= 0
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
		endOfLineEnc2NeighborMod1Threshold	= 0.065
		endOfLineEnc2NeighborMod1WireMinThreshold	= 0.07
		endOfLineEnc2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLineEnc2NeighborMod1SideKeepoutLength	= 0.07
		endOfLineEnc2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLineEnc2NeighborMod1MinEnclosure	= 0.03
		endOfLineEnc2NeighborMod1TblSize	= 2
		endOfLineEnc2NeighborMod1SpacingTbl	= (0.08,0.1)
		endOfLineEnc2NeighborMod1Tbl	= (0.05,0.03)
}

DesignRule	{
		layer1				= "M3"
		layer2				= "VIA2"
		minSpacing			= 0
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
		endOfLineEnc2NeighborMod1Threshold	= 0.065
		endOfLineEnc2NeighborMod1WireMinThreshold	= 0.07
		endOfLineEnc2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLineEnc2NeighborMod1SideKeepoutLength	= 0.07
		endOfLineEnc2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLineEnc2NeighborMod1MinEnclosure	= 0.03
		endOfLineEnc2NeighborMod1TblSize	= 2
		endOfLineEnc2NeighborMod1SpacingTbl	= (0.08,0.1)
		endOfLineEnc2NeighborMod1Tbl	= (0.05,0.03)
}

DesignRule	{
		layer1				= "M4"
		layer2				= "VIA3"
		minSpacing			= 0
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
		endOfLineEnc2NeighborMod1Threshold	= 0.065
		endOfLineEnc2NeighborMod1WireMinThreshold	= 0.07
		endOfLineEnc2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLineEnc2NeighborMod1SideKeepoutLength	= 0.07
		endOfLineEnc2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLineEnc2NeighborMod1MinEnclosure	= 0.03
		endOfLineEnc2NeighborMod1TblSize	= 2
		endOfLineEnc2NeighborMod1SpacingTbl	= (0.08,0.1)
		endOfLineEnc2NeighborMod1Tbl	= (0.05,0.03)
}

DesignRule	{
		layer1				= "M5"
		layer2				= "VIA4"
		minSpacing			= 0
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
		endOfLineEnc2NeighborMod1Threshold	= 0.065
		endOfLineEnc2NeighborMod1WireMinThreshold	= 0.07
		endOfLineEnc2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLineEnc2NeighborMod1SideKeepoutLength	= 0.07
		endOfLineEnc2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLineEnc2NeighborMod1MinEnclosure	= 0.03
		endOfLineEnc2NeighborMod1TblSize	= 2
		endOfLineEnc2NeighborMod1SpacingTbl	= (0.08,0.1)
		endOfLineEnc2NeighborMod1Tbl	= (0.05,0.03)
}

DesignRule	{
		layer1				= "M6"
		layer2				= "VIA5"
		minSpacing			= 0
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
		endOfLineEnc2NeighborMod1Threshold	= 0.065
		endOfLineEnc2NeighborMod1WireMinThreshold	= 0.07
		endOfLineEnc2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLineEnc2NeighborMod1SideKeepoutLength	= 0.07
		endOfLineEnc2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLineEnc2NeighborMod1MinEnclosure	= 0.03
		endOfLineEnc2NeighborMod1TblSize	= 2
		endOfLineEnc2NeighborMod1SpacingTbl	= (0.08,0.1)
		endOfLineEnc2NeighborMod1Tbl	= (0.05,0.03)
}

DesignRule	{
		layer1				= "M7"
		layer2				= "VIA6"
		minSpacing			= 0
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
		endOfLineEnc2NeighborMod1Threshold	= 0.065
		endOfLineEnc2NeighborMod1WireMinThreshold	= 0.07
		endOfLineEnc2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLineEnc2NeighborMod1SideKeepoutLength	= 0.07
		endOfLineEnc2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLineEnc2NeighborMod1MinEnclosure	= 0.03
		endOfLineEnc2NeighborMod1TblSize	= 2
		endOfLineEnc2NeighborMod1SpacingTbl	= (0.08,0.1)
		endOfLineEnc2NeighborMod1Tbl	= (0.05,0.03)
}

DesignRule	{
		layer1				= "M8"
		layer2				= "VIA7"
		minSpacing			= 0
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
		endOfLineEnc2NeighborMod1Threshold	= 0.065
		endOfLineEnc2NeighborMod1WireMinThreshold	= 0.07
		endOfLineEnc2NeighborMod1CornerKeepoutWidth	= 0.025
		endOfLineEnc2NeighborMod1SideKeepoutLength	= 0.07
		endOfLineEnc2NeighborMod1SideKeepoutWidth	= 0.115
		endOfLineEnc2NeighborMod1MinEnclosure	= 0.03
		endOfLineEnc2NeighborMod1TblSize	= 2
		endOfLineEnc2NeighborMod1SpacingTbl	= (0.08,0.1)
		endOfLineEnc2NeighborMod1Tbl	= (0.05,0.03)
}

DesignRule	{
		layer1				= "M1"
		layer2				= "CO"
		minSpacing			= 0
		fatWireViaEncTblSize		= 1
		fatWireViaEncWidthThresholdTbl	= (0.08)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06)
		fatWireViaEncParallelLengthThresholdTbl	= (0.18)
		fatWireViaEnclosureTbl		= (0.015)
}

DesignRule	{
		layer1				= "M1"
		layer2				= "VIA1"
		fatWireViaEncTblSize		= 1
		fatWireViaEncWidthThresholdTbl	= (0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1)
		fatWireViaEnclosureTbl		= (0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
}

DesignRule	{
		layer1				= "M2"
		layer2				= "VIA2"
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
}

DesignRule	{
		layer1				= "M3"
		layer2				= "VIA3"
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
}

DesignRule	{
		layer1				= "M4"
		layer2				= "VIA4"
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
}

DesignRule	{
		layer1				= "M5"
		layer2				= "VIA5"
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
}

DesignRule	{
		layer1				= "M6"
		layer2				= "VIA6"
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
}

DesignRule	{
		layer1				= "M7"
		layer2				= "VIA7"
		fatWireViaEncTblSize		= 4
		fatWireViaEncWidthThresholdTbl	= (0.055,0.06,0.075,0.165)
		fatWireViaEncMaxSpacingThresholdTbl	= (0.06,0.065,0.1,0.13)
		fatWireViaEncParallelLengthThresholdTbl	= (0.1,0.1,0.1,0.1)
		fatWireViaEnclosureTbl		= (0.005,0.005,0.01,0.015)
		fatWireViaEncCheckViaOffFatWire	= 1
}

DesignRule	{
		layer1				= "VIA1"
		layer2				= "VIA1"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		sameNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
		diffNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
}

DesignRule	{
		layer1				= "VIA2"
		layer2				= "VIA2"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		sameNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
		diffNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
}

DesignRule	{
		layer1				= "VIA3"
		layer2				= "VIA3"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		sameNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
		diffNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
}

DesignRule	{
		layer1				= "VIA4"
		layer2				= "VIA4"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		sameNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
		diffNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
}

DesignRule	{
		layer1				= "VIA5"
		layer2				= "VIA5"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		sameNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
		diffNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
}

DesignRule	{
		layer1				= "VIA6"
		layer2				= "VIA6"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		sameNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
		diffNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
}

DesignRule	{
		layer1				= "VIA7"
		layer2				= "VIA7"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		sameNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
		diffNetCornerMinSpacingTbl	= (0.07,0.075,
						   0.075,0.08)
}

DesignRule	{
		layer1				= "VIA2"
		layer2				= "VIA3"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		diffNetXMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
		diffNetYMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
}

DesignRule	{
		layer1				= "VIA3"
		layer2				= "VIA4"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		diffNetXMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
		diffNetYMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
}

DesignRule	{
		layer1				= "VIA4"
		layer2				= "VIA5"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		diffNetXMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
		diffNetYMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
}

DesignRule	{
		layer1				= "VIA5"
		layer2				= "VIA6"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		diffNetXMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
		diffNetYMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
}

DesignRule	{
		layer1				= "VIA6"
		layer2				= "VIA7"
		cut1TblSize			= 2
		cut2TblSize			= 2
		cut1NameTbl			= (Vsq,Vrect)
		cut2NameTbl			= (Vsq,Vrect)
		orthoSpacingExcludeCornerTbl	= (1,1,
						   1,1)
		diffNetXMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
		diffNetYMinSpacingTbl		= (0.06,0.06,
						   0.06,0.06)
}

PRRule		{
		rowSpacingTopTop		= 0
		rowSpacingTopBot		= 1.5
		rowSpacingBotBot		= 0
		abuttableTopTop			= 1
		abuttableTopBot			= 0
		abuttableBotBot			= 1
}

DensityRule	{
		layer				= "M1"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M1"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M2"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M2"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M3"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M3"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M4"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M4"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M5"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M5"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M6"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M6"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M7"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M7"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M8"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M8"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M9"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M9"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "M10"
		windowSize			= 125
		minDensity			= 10
		maxDensity			= 85
}

DensityRule	{
		layer				= "M10"
		windowSize			= 200
		maxGradientDensity		= 50
}

DensityRule	{
		layer				= "AP"
		windowSize			= 100
		minDensity			= 10
		maxDensity			= 70
}
