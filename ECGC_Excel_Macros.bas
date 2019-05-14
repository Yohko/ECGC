'Licence: GNU General Public License version 2 (GPLv2)

Sub GC_runall()
	Format_table
	Create_chargeplot
	Create_currentplot
	Create_Effplot
	Create_Effbarchart
End Sub


Sub update_barchart()
	Dim sSheetName As String
	sSheetName = ActiveSheet.Name
	' search for the position where the #N/A begin
	LastRow = ActiveSheet.Cells.Find(What:="#N/A", _
			After:=ActiveSheet.Range("BY1"), _
			Lookat:=xlPart, _
			LookIn:=xlValues, _
			SearchOrder:=xlByRows, _
			SearchDirection:=xlNext, _
			MatchCase:=False).Row - 1

	Dim rng As Range
	Dim labelrng As Range
	Set rng = ActiveSheet.Range("BX1:BX" & LastRow & ",BY1:BY" & LastRow & ",BZ1:BZ" & LastRow & ",CA1:CA" & LastRow & ",CB1:CB" & LastRow)
	Set labelrng = ActiveSheet.Range("BW2", "BW" & LastRow)

	ActiveChart.SetSourceData Source:=rng, PlotBy:=xlColumns
	ActiveChart.SeriesCollection(1).XValues = labelrng

	Dim c As Range
	Dim bottomA As Integer
	bottomA = Range("A" & Rows.Count).End(xlUp).Row
	For Each c In Range("BJ2:BJ" & bottomA)
		If IsEmpty(c.Value) Then
			c.EntireRow.Interior.ColorIndex = 0
		Else
			c.EntireRow.Interior.ColorIndex = 6
		End If
	Next c
End Sub


Sub Format_table()
	ExecuteExcel4Macro _
		"FORMULA.REPLACE(""="",""="",2,1,FALSE,FALSE,,FALSE,FALSE,FALSE,FALSE)"
	Columns("BD:BD").Select
	Selection.NumberFormat = "0.00"
End Sub


Sub Create_chargeplot()
	Range("BF1").Select

	Dim rng As Range
	Dim labelrng As Range
	Dim cht As Object
	Dim sSheetName As String
	sSheetName = ActiveSheet.Name

	Set rng = ActiveSheet.Range("BW1:BW" & Cells(Rows.Count, 1).End(xlUp).Row & ",CE1:CE" & Cells(Rows.Count, 1).End(xlUp).Row)
	Set labelrng = ActiveSheet.Range("BW2", "BW" & Cells(Rows.Count, 1).End(xlUp).Row)

	'Create a chart
	Set cht = ActiveSheet.ChartObjects.Add( _
		Left:=ActiveCell.Left, _
		Width:=350, _
		Top:=ActiveCell.Top, _
		Height:=250)

	'Determine the chart type
	cht.Chart.ChartType = xlXYScatterSmooth
 
	'Give chart some data
	cht.Chart.SetSourceData Source:=rng, PlotBy:=xlColumns
	cht.Chart.SeriesCollection(1).XValues = labelrng

	cht.Chart.DisplayBlanksAs = xlInterpolated
 
	'Ensure chart has a title
	cht.Chart.HasTitle = True
	'Change chart's title
	cht.Chart.ChartTitle.Text = "Charge plot"

	'Add Legend to the Right
	cht.Chart.SetElement (msoElementLegendRight)


	'Add X-axis title
	cht.Chart.Axes(xlCategory, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlCategory, xlPrimary).AxisTitle.Text = "U vs. RHE / V"


	'Add y-axis title
	cht.Chart.Axes(xlValue, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlValue, xlPrimary).AxisTitle.Text = "Q / C"

	Call format_graph(cht)
	Call format_linegraph(cht)
	cht.Chart.HasLegend = False
End Sub


Sub Create_currentplot()
	Range("BM18").Select

	Dim rng As Range
	Dim labelrng As Range
	Dim errorrng As Range
	Dim cht As Object
	Dim sSheetName As String
	sSheetName = ActiveSheet.Name

	Set rng = ActiveSheet.Range("BW1:BW" & Cells(Rows.Count, 1).End(xlUp).Row & ",CD1:CD" & Cells(Rows.Count, 1).End(xlUp).Row)
	Set labelrng = ActiveSheet.Range("BW2", "BW" & Cells(Rows.Count, 1).End(xlUp).Row)
	Set errorrng = ActiveSheet.Range("CF2", "CF" & Cells(Rows.Count, 1).End(xlUp).Row)

	'Create a chart
	Set cht = ActiveSheet.ChartObjects.Add( _
		Left:=ActiveCell.Left, _
		Width:=350, _
		Top:=ActiveCell.Top, _
		Height:=250)

	'Determine the chart type
	cht.Chart.ChartType = xlXYScatterSmooth
 
	'Give chart some data
	cht.Chart.SetSourceData Source:=rng, PlotBy:=xlColumns
	cht.Chart.SeriesCollection(1).XValues = labelrng

	cht.Chart.SeriesCollection(1).HasErrorBars = True
	cht.Chart.SeriesCollection(1).ErrorBars.Select
	cht.Chart.SeriesCollection(1).ErrorBar Direction:=xlY, Include:=xlBoth, _
		Type:=xlCustom, Amount:=errorrng, MinusValues:=errorrng

	cht.Chart.SeriesCollection(1).ErrorBar Direction:=xlX, Include:=xlErrorBarIncludeNone, Type:=xlStError

	cht.Chart.DisplayBlanksAs = xlInterpolated

	'Ensure chart has a title
	cht.Chart.HasTitle = True
	'Change chart's title
	cht.Chart.ChartTitle.Text = "Current plot"
	'Add Legend to the Right
	cht.Chart.SetElement (msoElementLegendRight)

	'Add X-axis title
	cht.Chart.Axes(xlCategory, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlCategory, xlPrimary).AxisTitle.Text = "U vs. RHE / V"

	'Add y-axis title
	cht.Chart.Axes(xlValue, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlValue, xlPrimary).AxisTitle.Text = "J / mA*cm^-2"

	Call format_graph(cht)
	Call format_linegraph(cht)
	cht.Chart.HasLegend = False
End Sub


Sub format_linegraph(cht As Object)
	cht.Chart.SeriesCollection(1).Format.Line.Weight = 1.5
	cht.Chart.SeriesCollection(1).Format.Shadow.Visible = msoFalse
	cht.Chart.SeriesCollection(1).Format.ThreeD.BevelTopType = msoBevelNone
	cht.Chart.SeriesCollection(1).Format.ThreeD.BevelBottomType = msoBevelNone
End Sub


Sub format_graph(cht As Object)
	cht.Chart.PlotArea.Border.LineStyle = xlContinuous
	cht.Chart.PlotArea.Border.ColorIndex = 1
	cht.Chart.Axes(xlValue).Border.Color = 1
	cht.Chart.Axes(xlValue).MajorTickMark = xlInside
	cht.Chart.Axes(xlValue).MinorTickMark = xlInside
	cht.Chart.Axes(xlCategory).Border.Color = 1
	cht.Chart.Axes(xlCategory).MajorTickMark = xlInside
	cht.Chart.Axes(xlCategory).MinorTickMark = xlInside
	cht.Chart.Axes(xlCategory).Crosses = xlMinimum
	cht.Chart.Axes(xlCategory).AxisTitle.Font.Size = 16
	cht.Chart.Axes(xlCategory).AxisTitle.Font.Name = "Times New Roman"
	cht.Chart.Axes(xlValue).AxisTitle.Font.Size = 16
	cht.Chart.Axes(xlValue).AxisTitle.Font.Name = "Times New Roman"
	cht.Chart.Axes(xlCategory).TickLabels.Font.Size = 12
	cht.Chart.Axes(xlCategory).TickLabels.Font.Name = "Times New Roman"
	cht.Chart.Axes(xlValue).TickLabels.Font.Size = 12
	cht.Chart.Axes(xlValue).TickLabels.Font.Name = "Times New Roman"
	cht.Chart.Legend.Font.Size = 12
	cht.Chart.Legend.Font.Name = "Times New Roman"
	cht.Chart.HasTitle = False
End Sub


Sub Create_Effplot()
	Range("BF18").Select

	Dim rng As Range
	Dim errorrng As Range

	Dim cht As Object
	Dim sSheetName As String
	sSheetName = ActiveSheet.Name

	Set rng = ActiveSheet.Range("BW:CC")
	Set errorrng = ActiveSheet.Range("CG2:CG" & Cells(Rows.Count, 1).End(xlUp).Row & ",CL2:CK" & Cells(Rows.Count, 1).End(xlUp).Row)

	'Create a chart
	Set cht = ActiveSheet.ChartObjects.Add( _
		Left:=ActiveCell.Left, _
		Width:=350, _
		Top:=ActiveCell.Top, _
		Height:=250)

	'Determine the chart type
	cht.Chart.ChartType = xlXYScatterSmooth

	'Give chart some data
	cht.Chart.SetSourceData Source:=rng


	'CO
	cht.Chart.SeriesCollection(1).HasErrorBars = True
	cht.Chart.SeriesCollection(1).ErrorBars.Select
	cht.Chart.SeriesCollection(1).ErrorBar Direction:=xlY, Include:=xlBoth, _
		Type:=xlCustom, _
		Amount:=ActiveSheet.Range("CG2", "CG" & Cells(Rows.Count, 1).End(xlUp).Row), _
		MinusValues:=ActiveSheet.Range("CG2", "CG" & Cells(Rows.Count, 1).End(xlUp).Row)

	cht.Chart.SeriesCollection(1).ErrorBar Direction:=xlX, Include:=xlErrorBarIncludeNone, Type:=xlStError

	'CH4
	cht.Chart.SeriesCollection(2).HasErrorBars = True
	cht.Chart.SeriesCollection(2).ErrorBars.Select
	cht.Chart.SeriesCollection(2).ErrorBar Direction:=xlY, Include:=xlBoth, _
		Type:=xlCustom, _
		Amount:=ActiveSheet.Range("CH2", "CH" & Cells(Rows.Count, 1).End(xlUp).Row), _
		MinusValues:=ActiveSheet.Range("CH2", "CH" & Cells(Rows.Count, 1).End(xlUp).Row)

	cht.Chart.SeriesCollection(2).ErrorBar Direction:=xlX, Include:=xlErrorBarIncludeNone, Type:=xlStError

	'C2H4
	cht.Chart.SeriesCollection(3).HasErrorBars = True
	cht.Chart.SeriesCollection(3).ErrorBars.Select
	cht.Chart.SeriesCollection(3).ErrorBar Direction:=xlY, Include:=xlBoth, _
		Type:=xlCustom, _
		Amount:=ActiveSheet.Range("CI2", "CI" & Cells(Rows.Count, 1).End(xlUp).Row), _
		MinusValues:=ActiveSheet.Range("CI2", "CI" & Cells(Rows.Count, 1).End(xlUp).Row)

	cht.Chart.SeriesCollection(3).ErrorBar Direction:=xlX, Include:=xlErrorBarIncludeNone, Type:=xlStError

	'C2H6
	cht.Chart.SeriesCollection(4).HasErrorBars = True
	cht.Chart.SeriesCollection(4).ErrorBars.Select
	cht.Chart.SeriesCollection(4).ErrorBar Direction:=xlY, Include:=xlBoth, _
		Type:=xlCustom, _
		Amount:=ActiveSheet.Range("CJ2", "CJ" & Cells(Rows.Count, 1).End(xlUp).Row), _
		MinusValues:=ActiveSheet.Range("CJ2", "CJ" & Cells(Rows.Count, 1).End(xlUp).Row)

	cht.Chart.SeriesCollection(4).ErrorBar Direction:=xlX, Include:=xlErrorBarIncludeNone, Type:=xlStError

	'H2
	cht.Chart.SeriesCollection(5).HasErrorBars = True
	cht.Chart.SeriesCollection(5).ErrorBars.Select
	cht.Chart.SeriesCollection(5).ErrorBar Direction:=xlY, Include:=xlBoth, _
		Type:=xlCustom, _
		Amount:=ActiveSheet.Range("CK2", "CK" & Cells(Rows.Count, 1).End(xlUp).Row), _
		MinusValues:=ActiveSheet.Range("CK2", "CK" & Cells(Rows.Count, 1).End(xlUp).Row)

	cht.Chart.SeriesCollection(5).ErrorBar Direction:=xlX, Include:=xlErrorBarIncludeNone, Type:=xlStError

	'Total
	cht.Chart.SeriesCollection(6).HasErrorBars = True
	cht.Chart.SeriesCollection(6).ErrorBars.Select
	cht.Chart.SeriesCollection(6).ErrorBar Direction:=xlY, Include:=xlBoth, _
		Type:=xlCustom, _
		Amount:=ActiveSheet.Range("CL2", "CL" & Cells(Rows.Count, 1).End(xlUp).Row), _
		MinusValues:=ActiveSheet.Range("CL2", "CL" & Cells(Rows.Count, 1).End(xlUp).Row)

	cht.Chart.SeriesCollection(6).ErrorBar Direction:=xlX, Include:=xlErrorBarIncludeNone, Type:=xlStError

	cht.Chart.DisplayBlanksAs = xlInterpolated

	'Ensure chart has a title
	cht.Chart.HasTitle = True
	'Change chart's title
	cht.Chart.ChartTitle.Text = "Faradaic Efficiency plot"

	'Add X-axis title
	cht.Chart.Axes(xlCategory, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlCategory, xlPrimary).AxisTitle.Text = "U vs. RHE / V"
	'Add y-axis title
	cht.Chart.Axes(xlValue, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlValue, xlPrimary).AxisTitle.Text = "F. E. / %"
	'Adjust y-axis Scale
	cht.Chart.Axes(xlValue).MinimumScale = 0
	cht.Chart.Axes(xlValue).MaximumScale = 100

	Call format_graph(cht)
	Call format_linegraph(cht)
End Sub


Sub Create_Effbarchart()
	Range("BM1").Select
	Dim rng As Range
	Dim labelrng As Range
	Dim cht As Object
	Dim sSheetName As String
	sSheetName = ActiveSheet.Name
	Set rng = ActiveSheet.Range("BX:CB")
	Set labelrng = ActiveSheet.Range("BW2", "BW" & Cells(Rows.Count, 1).End(xlUp).Row)


	'Create a chart
	Set cht = ActiveSheet.ChartObjects.Add( _
		Left:=ActiveCell.Left, _
		Width:=350, _
		Top:=ActiveCell.Top, _
		Height:=250)

	'Determine the chart type
	cht.Chart.ChartType = xlColumnStacked

	'Give chart some data
	cht.Chart.SetSourceData Source:=rng, PlotBy:=xlColumns
	cht.Chart.SeriesCollection(1).XValues = labelrng
	cht.Chart.DisplayBlanksAs = xlNotPlotted

	'Ensure chart has a title
	cht.Chart.HasTitle = True
	'Change chart's title
	cht.Chart.ChartTitle.Text = "Faradaic Efficiency Bar Chart"
	cht.Chart.Axes(xlCategory, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlCategory, xlPrimary).AxisTitle.Text = "U vs. RHE / V"

	'Add y-axis title
	cht.Chart.Axes(xlValue, xlPrimary).HasTitle = True
	cht.Chart.Axes(xlValue, xlPrimary).AxisTitle.Text = "F. E. / %"

	'Add Major Gridlines
	cht.Chart.SetElement (msoElementPrimaryValueGridLinesMajor)
	'Adjust y-axis Scale
	cht.Chart.Axes(xlValue).MinimumScale = 0
	cht.Chart.Axes(xlValue).MaximumScale = 100

	'Adjust Bar Gap
	cht.Chart.ChartGroups(1).GapWidth = 20

	'CO
	cht.Chart.SeriesCollection(1).Interior.Color = RGB(192, 80, 77)
	'CH4
	cht.Chart.SeriesCollection(2).Interior.Color = RGB(128, 100, 162)
	'C2H4
	cht.Chart.SeriesCollection(3).Interior.Color = RGB(79, 129, 189)
	'C2H6
	cht.Chart.SeriesCollection(4).Interior.Color = RGB(79, 255, 255)
	'H2
	cht.Chart.SeriesCollection(5).Interior.Color = RGB(155, 187, 89)

	Call format_graph(cht)
End Sub
