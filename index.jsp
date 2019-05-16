<!DOCTYPE html>
<html lang="zh">

	<head>
		<title>工作流程图</title>
		<meta charset="utf-8" />
		<link rel="stylesheet" type="text/css" href="css/style.css" />
	</head>

	<body>
		<div class="fuchuang">
			<div class="fuqu">
				<p><input type="text" class="inputcont" /> <span class="sureaaa">修改名称</span>
					<input type="button" value="删除连线" class="cancalline" /> </p>
			</div>
		</div>
		<div class="top-panel">
			<div class="top-left-panel" style="width:200px;">
				<input type="button" class="fl-btn" id="btn-object" value="部件" />
			</div>
			<div class="top-left-panel">
				<input type="button" class="fl-btn" id="new-box" value="新建流程图" />
			</div>
			<div class="top-left-panel">
				<input type="button" class="fl-btn" id="creat_img" value="载入json数据" />
			</div>
			<div class="top-left-panel">
				<input type="button" class="fl-btn" id="chart-save" value="查看json数据" />
			</div>
			<div class="top-left-panel">
				<input type="button" class="fl-btn" id="line-mode" value="线条样式" />
			</div>
			<div class="top-right-panel">
				<input type="button" class="fl-btn" id="text-chart-align" value="文字方向" />
			</div>
			<div class="top-right-panel">
				<input type="button" class="fl-btn" id="text-font-style" value="文字样式" />
			</div>
			<div class="top-right-panel">
				<input type="button" class="fl-btn" id="border-selector-style" value="流程图区域背景色" />
			</div>
		</div>
		<div class="chart-content">
			<div id="chart-container" class="chart-design droppable"></div>
			<div class="chart-right-panel">
				<div class="chart-right-list">
					<div class="chart-right-list-flag" style="display:none;visibility:hidden;">
					</div>
					<div class="chart-list chart-object">
						<h4>可拖拽元素</h4>
						<div class="list-content">
							<div class="area">
								<div class="draggable" id="rect">讨论需求</div>
								<div class="draggable" id="rect">制定方案</div>
								<div class="draggable" id="rect">程序开发</div>
								<div class="draggable" id="rect">发布上线</div>
								<div class="draggable" id="rect">
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="line-select" id="line-select-div" style="display:none">
				<div class="chart-list chart-stylex">
					<h4 class="top-menu-selector" id="line-Straight">直线</h4>
					<h4 class="top-menu-selector" id="line-Bezier">曲线</h4>
					<h4 class="top-menu-selector" id="line-Flowchart">流程线</h4>
				</div>
			</div>
			<div class="line-select" id="align-select-div" style="display:none">
				<div class="chart-list chart-stylex">
					<h4 class="top-menu-selector" id="align-left">居左</h4>
					<h4 class="top-menu-selector" id="align-center">居中</h4>
					<h4 class="top-menu-selector" id="align-right">居右</h4>
				</div>
			</div>
			<div class="line-select" id="text-select-div" style="display:none">
				<div class="chart-list chart-stylex">
					<h4 class="fl-font-style" id="B">bold</h4>
					<h4 class="fl-font-style" id="I">italic</h4>
					<h4 class="fl-font-style" id="U">underline</h4>
				</div>
			</div>
			<div class="line-select" id="border-selector-div" style="display:none">
				<div class="chart-list chart-stylex">
					<h4 class="right-style-selector" id="blue">蓝色</h4>
					<h4 class="right-style-selector" id="white">白色</h4>
					<h4 class="right-style-selector" id="pink">粉色</h4>
					<h4 class="right-style-selector" id="dark">黑色</h4>
					<h4 class="right-style-selector" id="purple">紫色</h4>
				</div>
			</div>
			<!--自定义右键菜单html代码-->
			<div id="menu">
				<div class="menu" onclick="menu_operate();">功能1</div>
				<div class="menu">功能2</div>
				<div class="menu">功能3</div>
				<div class="menu">功能4</div>
				<div class="menu">功能5</div>
			</div>
		</div>
		<div class="save-form" style="display:none">
			<div class="save-heading">
				保存
				<span style="float:right;padding-right:20px">&times;</span>
			</div>
			<div class="save-json">
				<h5>json数据:</h5>
				<textarea id="save-json-form-display" style="height:300px;"></textarea>
			</div>
			<div class="save-img">
				<p> <button class="creat_newimg">保存信息 </button></p>
			</div>
		</div>
		<script src="js/jquery.js"></script>
		<script src="js/jquery-ui.js"></script>
		<script src="js/jquery.jsPlumb-1.4.0-all.js"></script>
		<script src="js/html2canvas.js"></script>
		<script type="text/javascript">
			//标识右侧工具栏是否已显示,默认显示
			sessionStorage['rightToolsIsDisplay'] = true;
			//标识当前点击的流程图框,默认为none
			sessionStorage['currentChartSelected'] = 'none';
			//栈,记录用户操作的先后顺序,用来进行撤销操作,数据结构为JSON,其中的copy用来复制部件
			//是个二维栈,包括新增/删除/粘贴操作
			var chartOperationStack = new Array;
			chartOperationStack['add'] = [];
			chartOperationStack['delete'] = [];
			chartOperationStack['paste'] = [];
			chartOperationStack['copy'] = [];
			//记录用户具体操作,有copy,add,delete,paste
			var chartRareOperationStack = new Array;
			//记录当前流程框的数量
			sessionStorage['currentChartAmount'] = 0;
			//指定流程图设计区域宽度高度
			function adjustDesignWidth() {
				var designWidth = 0;
				var domWidth = $(window).width();
				designWidth = domWidth - $('.chart-right-panel').width();
				$('.chart-design').css('width', designWidth - 4);
			}
			//对页面进行缩小或放大
			function setZoom(instance, scale, container) {
				//jsPlumb.setContainer("chart-container");
				$("#" + container).css({
					"-webkit-transform": "scale(" + scale + ")",
					"-moz-transform": "scale(" + scale + ")",
					"-ms-transform": "scale(" + scale + ")",
					"-o-transform": "scale(" + scale + ")",
					"transform": "scale(" + scale + ")",
					"TransformOrigin": "0% 0%"
				});
				instance.setZoom(scale);
			}
			//滑动条改变时触发的事件
			function ratioDisplay() {
				var chartRatioDom = document.getElementById('rear-ratio');
				var chartRatioDisplayDom = document.getElementById('rear-ratio-display');
				chartRatioDisplayDom.value = chartRatioDom.value;
				setZoom(jsPlumb, chartRatioDom.value / 100, 'chart-container');
				$('#chart-container').css({
					'left': '0px',
					'right': '180px'
				});
			}
			//大小选择框值改变时触发
			function ratioDisplay2() {
				var chartRatioDisplayDom = document.getElementById('rear-ratio-display');
				var chartRatioDom = document.getElementById('rear-ratio');
				chartRatioDom.value = chartRatioDisplayDom.value;
				setZoom(jsPlumb, chartRatioDisplayDom.value / 100, 'chart-container');
				$('#chart-container').css({
					'left': '0px',
					'right': '180px'
				});
			}
			//设置右边属性栏当前显示的是哪个工具(object/text/style)
			function setChartRightListFlag(value) {
				$('.chart-right-list-flag').html(value);
			}
			//获得当前右边属性栏当前显示的是哪个工具(object/text/style)
			function getChartRightListFlag() {
				return $('.chart-right-list-flag').html();
			}
			//负责属性面板的切换,
			//参数will代表即将要切换的属性面板[text|object|style]
			//参数current代表当前属性面板,可由getChartRightListFlag()获得
			function attrToggle(will, current) {
				if(sessionStorage['rightToolsIsDisplay'] == 'false') {
					$('.chart-right-panel').show();
					sessionStorage['rightToolsIsDisplay'] = true;
					if(current != will) {
						$('.chart-design').css("right", "230px");
						$(".chart-" + current).hide();
						$('.chart-' + will).fadeIn();
						setChartRightListFlag(will);
					}
					$('.chart-design').css("right", "0px");
				} else {
					$('.chart-right-panel').hide();
					sessionStorage['rightToolsIsDisplay'] = false;
					//递归调用切换属性面板函数
					attrToggle(will, current);
					$('.chart-design').css("right", "0px"); //扩充设计区域宽度
					if(will == current) {
						//如果当前点击的和将要切换的属性面板相同则隐藏整个右侧
						$('.chart-right-panel').hide();
						sessionStorage['rightToolsIsDisplay'] = false;
					} else {
						//如果当前点击和将要切换的属性面板不同则缩小设计区域宽度
						$('.chart-design').css("right", "0px");
					}
				}
			}
			//****************负责属性面板的内容设置*****************
			//设置当前部件top,left
			function setChartLocation(top, left) {
				$('#lo-x-display').val(top);
				$('#lo-y-display').val(left);
			}
			//获得当前部件top,left,返回一个数组,第一个元素是'top',第二个元素是'left'
			function getChartLocation() {
				var location = new Array();
				location['top'] = $('#lo-x-display').val();
				location['left'] = $('#lo-y-display').val();
				return location;
			}
			//设置当前部件的width和height
			function setChartSize(width, height) {
				$('#chart-width-display').val(width);
				$('#chart-height-display').val(height);
			}
			//获得当前部件的width和height,返回一个数组,第一个元素是'width',第二个元素是'height'
			function getChartSize() {
				var size = new Array();
				size['width'] = $('#chart-width-display').val();
				size['height'] = $('#chart-height-display').val();
				return size;
			}
			//设置当前部件的字体
			function setChartFont(font) {
				$('#chart-font-display').val(font);
			}

			function getChartFont() {
				var font = $('#' + sessionStorage['currentChartSelected']).css('font');
				return(font == '') ? '微软雅黑' : font;
			}
			//设置当前部件的字体大小
			function setChartFontSize(size) {
				$('#chart-font-size-display').val(size);
			}
			//取当前部件的字体大小
			function getChartFontSize() {
				var fontSize = $('#' + sessionStorage['currentChartSelected']).css('font-size');
				return(fontSize == '') ? 12 : fontSize.substring(0, fontSize.length - 2);
			}
			//设置当前部件的对齐方式
			function setChartAlign(lign) {
				$('#btn-align-' + lign).addClass('fl-align-style-active');
				if(lign == 'left') {
					$('#btn-align-right').removeClass('fl-align-style-active');
					$('#btn-align-center').removeClass('fl-align-style-active');
					$('#btn-align-none').removeClass('fl-align-style-active');
				}
				if(lign == 'right') {
					$('#btn-align-left').removeClass('fl-align-style-active');
					$('#btn-align-center').removeClass('fl-align-style-active');
					$('#btn-align-none').removeClass('fl-align-style-active');
				}
				if(lign == 'center') {
					$('#btn-align-left').removeClass('fl-align-style-active');
					$('#btn-align-right').removeClass('fl-align-style-active');
					$('#btn-align-none').removeClass('fl-align-style-active');
				}
				if(lign == 'none') {
					$('#btn-align-left').removeClass('fl-align-style-active');
					$('#btn-align-center').removeClass('fl-align-style-active');
					$('#btn-align-right').removeClass('fl-align-style-active');
				}
			}
			//取当前部件的对齐方式
			function getChartAlign() {
				var align = $('#' + sessionStorage['currentChartSelected']).css('text-align');
				return(align == '') ? 'center' : align;
			}
			//设置当前部件的字体颜色,参数color只能为rgb或16进制颜色值
			function setChartFontColor(color) {
				$('#chart-font-color-display').val(color);
			}
			//取当前部件的字体颜色
			function getChartFontColor() {
				var color = $('#' + sessionStorage['currentChartSelected']).css('color');
				return(color == '') ? 'rgb(0,0,0)' : color;
			}
			//设置json展示框的数据
			function setChartJson2Box(json) {
				$('#json-display-area').val(json);
			}
			//设置当前部件的border-radius
			function setChartBorderRadius(radius) {
				$('#chart-border-display').attr('value', radius);
			}
			//取当前部件的border
			function getChartBorderRadius() {
				var radius = $('#' + sessionStorage['currentChartSelected']).css('border-top-left-radius');
				return(radius == '') ? '0' : radius;
			}
			//设置当前部件的border
			function setChartBorderLineStyle(style) {
				$(".chart-fill-border-selector").val(style);
			}
			//取当前部件的border
			function getChartBorderLineStyle() {
				//console.log(document.getElementById(sessionStorage['currentChartSelected']).style.border);
				var style = $('#' + sessionStorage['currentChartSelected']).css('border-left-style');
				return(style == '') ? 'solid' : style;
			}
			//设置当前部件的border-width
			function setChartBorderWidthStyle(style) {
				$('#chart-fill-border-width-display').val(style);
			}
			//获得当前部件的border-width
			function getChartBorderWidthStyle() {
				var style = $('#' + sessionStorage['currentChartSelected']).css('border-left-width');
				return(style == '') ? '2' : style.split('px')[0];
			}
			//设置当前部件的border-color
			function setChartBorderColorStyle(style) {
				$('#chart-fill-border-color-display').attr('value', style);
			}
			//取得当前部件的border-color
			function getChartBorderColorStyle() {
				var style = $('#' + sessionStorage['currentChartSelected']).css('border-left-color');
				return(style == '') ? 'rgb(0,0,0)' : style;
			}
			//设置当前部件的填充背景色
			function setChartBackgroundColor(color) {
				$('#chart-background-color-display').attr('value', color);
			}
			//取当前部件的填充背景色
			function getChartBackgroundColor() {
				var bg = $('#' + sessionStorage['currentChartSelected']).css('backgroundColor');
				return(bg == '') ? 'rgb(255,255,255)' : bg;
			}
			//设置当前部件的渐近度
			function setChartBlurRange(range) {
				$('#chart-blur-range-display').attr('value', range);
			}
			//取当前部件的渐近度
			function getChartBlurRange() {
				var range = $('#' + sessionStorage['currentChartSelected']).css('box-shadow');
				return(range == 'none') ? '0' : range;
			}
			//设置当前部件的渐近色
			function setChartBlurColor(color) {
				$('#chart-fill-blur-color-display').attr('value', color);
			}
			//通过颜色选择器选择渐近色
			function getChartBlurColorByColorSelector() {
				return $('#chart-fill-blur-color-display').val();
			}
			//取当前部件的渐近色
			function getChartBlurColor() {
				var color = $('#' + sessionStorage['currentChartSelected']).css('boxShadow');
				return(color == 'none') ? 'rgb(255,255,255)' : color;
			}
			//设置当前部件的水平阴影
			function setChartHShadow(h) {
				$('#chart-h-shadow-display').val(h);
			}
			//取得当前部件的水平阴影
			function getChartHShadow() {
				var h = $('#' + sessionStorage['currentChartSelected']).css('boxShadow');
				return(h == 'none') ? '0' : h;
			}
			//通过选择器获得水平阴影
			function getChartHShadowBySelector() {
				return $('#chart-h-shadow-display').val();
			}
			//设置当前部件的垂直阴影
			function setChartVShadow(v) {
				$('#chart-v-shadow-display').val(v);
			} //取得当前部件的垂直阴影
			function getChartVshadow() {
				var v = $('#' + sessionStorage['currentChartSelected']).css('boxShadow');
				return(v == 'none') ? '0' : v;
			} //通过选择器获得垂直阴影
			function getChartVShadowBySelector() {
				return $('#chart-v-shadow-display').val();
			} //设置当前部件的模糊距离
			function setChartShadowBlur(blur) {
				$('#chart-shadow-blur-display').val(blur);
			} //取得当前部件的模糊距离
			function getChartShadowBlur() {
				var blur = $('#' + sessionStorage['currentChartSelected']).css('boxShadow');
				return(blur == 'blur') ? '0' : blur;
			} //通过选择器获得模糊距离
			function getChartShadowBlurBySelector() {
				return $('#chart-shadow-blur-display').val();
			} //设置当前部件的阴影尺寸
			function setChartShadowSpread(spread) {
				$('#chart-shadow-spread-display').val(spread);
			} //取得当前部件的阴影尺寸
			function getChartShadowSpread() {
				var spread = $('#' + sessionStorage['currentChartSelected']).css('boxShadow');
				return(spread == 'blur') ? '0' : spread;
			} //通过选择器获得阴影尺寸
			function getChartShadowSpreadBySelector() {
				return $('#chart-shadow-spread-display').val();
			} //设置当前部件的阴影颜色
			function setChartShadowColor(color) {
				$('#chart-shadow-color-display').val(color);
			} //通过颜色选择器获取当前部件的阴影颜色
			function getChartShadowColorBySelector() {
				return $('#chart-shadow-color-display').val();
			} //取得当前部件的阴影颜色
			function getChartShadowColor() {
				var color = $('#' + sessionStorage['currentChartSelected']).css('box-shadow');
				return(color == 'none') ? 'rgb(255,255,255)' : color;
			}
			//设置属性栏的按钮样式
			function setChartFontStyleBtn(style) {
				if(style != 'normal') {
					var singleStyle = style.split('|');
					for(var i = 0; i < singleStyle.length - 1; i++) {
						$('#' + singleStyle[i]).addClass('fl-font-style-active');
					};
				} else {
					$('#B,#I,#U').removeClass('fl-font-style-active');
				}
			}
			//取当前部件的font-style
			function getChartFontStyle(id) {
				if(id != '') {
					var style = '';
					if($('#' + id).hasClass('fl-font-style-bold')) {
						style += 'B|';
					}
					if($('#' + id).hasClass('fl-font-style-italic')) {
						style += 'I|';
					}
					if($('#' + id).hasClass('fl-font-style-underline')) {
						style += 'U|';
					}
					if(style != '') {
						return style;
					} else {
						return 'normal';
					}
				}
			} //设置文字高度
			function setChartLineHeight(height) {
				$('#chart-font-height-display').val(height);
			} //取得文字高度
			function getChartLineHeight() {
				var height = $('#' + sessionStorage['currentChartSelected']).css('line-height');
				return(height == '') ? '0' : height.split('px')[0];
			} //设置文字间距
			function setChartLetterSpacing(space) {
				$('#chart-font-spacing-display').val(space);
			} //取得文字间距
			function getChartLetterSpacing() {
				var space = $('#' + sessionStorage['currentChartSelected']).css('letterSpacing');
				return(space == '') ? '0' : space;
			} //****************负责属性面板的内容设置*****************

			//*********************************jsPlumb基础信息配置区域*********************************

			//流程图ID唯一标识,用来防止重复,每次新建一个部件时此值必须加1,否则会出现异常
			sessionStorage['idIndex'] = 0;

			//检测设计区域中间区域是否被占据,页面刚加载时默认没有被占据
			sessionStorage['midIsOccupied'] = 'not';

			//根蒂根基连接线样式
			var connectorPaintStyle = {
				lineWidth: 2,
				strokeStyle: "rgb(0,32,80)",
				joinstyle: "round",
				outlineColor: "rgb(251,251,251)",
				outlineWidth: 2
			};

			// 鼠标悬浮在连接线上的样式
			var connectorHoverStyle = {
				lineWidth: 2,
				strokeStyle: "#216477",
				outlineWidth: 0,
				outlineColor: "rgb(251,251,251)"
			};

			var hollowCircle = {
				endpoint: ["Dot", {
					radius: 4
				}], //端点的外形
				connectorStyle: connectorPaintStyle, //连接线的色彩,大小样式
				connectorHoverStyle: connectorHoverStyle,
				paintStyle: {
					strokeStyle: "rgb(0,32,80)",
					fillStyle: "rgb(0,32,80)",
					opacity: 0.5,
					radius: 2,
					lineWidth: 2
				}, //端点的色彩样式
				//anchor: "AutoDefault",
				isSource: true, //是否可以拖动(作为连线出发点)
				//connector: ["Flowchart", { stub: [40, 60], gap: 10, cornerRadius: 5, alwaysRespectStubs: true }],  //连接线的样式种类有[Bezier],[Flowchart],[StateMachine ],[Straight ]
				connector: ["Flowchart", {
					curviness: 100
				}], //设置连线为贝塞尔曲线
				isTarget: true, //是否可以放置(连线终点)
				maxConnections: -1, // 设置连接点最多可以连接几条线
				connectorOverlays: [
					["Arrow", {
						width: 20,
						length: 20,
						location: 1
					}]
				]
			};

			//设置线条展现方式为Straight
			function setLineStraight() {
				hollowCircle['connector'][0] = 'Straight';
			}

			//设置线条展现方式为Bezier
			function setLineBezier() {
				hollowCircle['connector'][0] = 'Bezier';
			}

			//设置线条展现方式为Flowchart
			function setLineFlowchart() {
				hollowCircle['connector'][0] = 'Flowchart';
			}

			//灵活设置线条表现方式,参数type只能为Straight|Bezier|Flowchart
			function setChartLineType(type) {
				hollowCircle['connector'][0] = type;
			}

			//设置流程框内字体对齐方式
			//参数type只能为left,right或者center
			//参数ele若留空则默认全局设置,默认为空
			function setChartTextAlign(ele, type) {
				ele = (arguments[0] == '') ? '' : arguments[0];
				if(ele == '') {
					$('.draggable').css('text-align', type);
				} else {
					$("#" + ele).css('text-align', type);
				}
			}

			//*********************************jsPlumb基础信息配置区域*********************************

			//*********************************流程图数据操作区域*********************************
			var list = jsPlumb.getAllConnections();
			//序列化全部流程图数据,json格式
			function save() {

				list = jsPlumb.getAllConnections();

				var connects = [];

				for(var i in list) {
					for(var j in list[i]) {

						connects.push({
							ConnectionId: list[i][j]['id'],
							PageSourceId: list[i][j]['sourceId'],
							PageTargetId: list[i][j]['targetId'],
							Connectiontext: list[i][j].getLabel(),
							PageSourceType: list[i][j].endpoints[0].anchor.type,
							PageTargetType: list[i][j].endpoints[1].anchor.type,
						});
					}
				}

				var blocks = [];
				$(".droppable .draggable").each(function(idx, elem) {
					var elem = $(elem);
					var rareHTML = elem.html();
					var resultHTML = rareHTML;
					//去掉在进行复制操作时误复制的img部件
					if(rareHTML.indexOf('<img src=\"img/delete.png\"') != -1) {
						rareHTML = rareHTML.split('<img src=\"img/delete.png\"');
						resultHTML = rareHTML[0];
					}

					if(resultHTML.indexOf('<div style="z-index: 90;" ') != -1) {
						resultHTML = resultHTML.split('<div style="z-index: 90;" ')[0];
					}

					/**********************字体**********************/
					//字体
					var Bfont = elem.css("font");
					//字体颜色
					var fontSize = elem.css('font-size');
					//字体对齐方式
					var fontAlign = elem.css('text-align');
					//字体颜色
					var fontColor = elem.css('color');

					(Bfont == '') ? Bfont = "微软雅黑": Bfont;
					(fontSize == '') ? fontSize = '12': fontSize;
					(fontAlign == '') ? fontAlign = 'center': fontAlign;
					(fontColor == '') ? fontColor = 'rgb(0,0,0)': fontColor;

					/**********************物件**********************/
					//圆角
					var borderRadius = elem.css('borderRadius');
					var elemType = elem.attr('id').split('-')[0];
					(borderRadius == '') ? borderRadius = '0': borderRadius;
					//如果当前部件是圆角矩形,且borderRadius为空或者为0就把默认borderradius设置为4,下同
					(elemType == 'roundedRect' && (borderRadius == '' || borderRadius == '0')) ? borderRadius = '4': borderRadius;
					(elemType == 'circle' && (borderRadius == '' || borderRadius == '0')) ? borderRadius = '15': borderRadius;
					//填充
					var fillColor = elem.css('backgroundColor');
					(fillColor == '') ? fillColor = 'rgb(255,255,255)': fillColor;
					//渐近度
					var fillBlurRange = elem.css('boxShadow'); //rgb(0, 0, 0) 10px 10px 17px 20px inset
					var fillBlurSplit = fillBlurRange.split(' ');
					(fillBlurRange == '') ? fillBlurRange = '0': fillBlurRange = fillBlurSplit[5];
					//渐近色
					var fillBlurColor = fillBlurSplit[0] + fillBlurSplit[1] + fillBlurSplit[2];
					//线框样式
					var borderStyle = elem.css('border-left-style');
					(borderStyle == '') ? borderStyle = 'solid': borderStyle;
					//线框宽度
					var borderWidth = elem.css('border-left-width');
					(borderWidth == '') ? borderWidth = '2': borderWidth.split('px')[0];
					//线框颜色
					var borderColor = elem.css('border-left-color');
					(borderColor == '') ? borderColor = 'rgb(136,242,75)': borderColor;

					//阴影数据
					var shadow = elem.css('box-shadow');

					//字体样式数据
					var fontStyle = elem.css('fontStyle');
					var fontWeight = elem.css('fontWeight');
					var fontUnderline = elem.css('textDecoration');

					//文字高度
					var lineHeight = elem.css('line-height');

					blocks.push({
						BlockId: elem.attr('id'),
						BlockContent: resultHTML,
						BlockX: parseInt(elem.css("left"), 10),
						BlockY: parseInt(elem.css("top"), 10),
						BlockWidth: parseInt(elem.css("width"), 10),
						BlockHeight: parseInt(elem.css("height"), 10),
						BlockFont: Bfont,
						BlockFontSize: fontSize,
						BlockFontAlign: fontAlign,
						BlockFontColor: fontColor,
						BlockBorderRadius: borderRadius,
						BlockBackground: fillColor,
						BlockFillBlurRange: fillBlurRange,
						BlockFillBlurColor: fillBlurColor,
						BlockBorderStyle: borderStyle,
						BlockBorderWidth: borderWidth,
						BlockborderColor: borderColor,
						BlockShadow: shadow,
						BlockFontStyle: fontStyle,
						BlockFontWeight: fontWeight,
						BlockFontUnderline: fontUnderline,
						BlockLineHeight: lineHeight
					});

				});

				var serliza = "{" + '"connects":' + JSON.stringify(connects) + ',"block":' + JSON.stringify(blocks) + "}";
				console.log(serliza);
				return serliza;
			}

			//生成单个流程图数据,用在新建流程图框时使用
			//参数ID表示被push进栈的ID
			function getSingleChartJson(id) {

				var connects = [];

				for(var i in list) {
					for(var j in list[i]) {
						connects.push({
							ConnectionId: list[i][j]['id'],
							PageSourceId: list[i][j]['sourceId'],
							PageTargetId: list[i][j]['targetId'],
							Connectiontext: list[i][j].getLabel(),
							PageSourceType: list[i][j].endpoints[0].anchor.type,
							PageTargetType: list[i][j].endpoints[1].anchor.type,
						});
					}
				}
				var blocks = [];
				var elem = $("#" + id);
				var rareHTML = elem.html();
				var resultHTML = rareHTML;
				//console.log(rareHTML);
				//去掉在进行复制操作时误复制的img部件
				if(rareHTML.indexOf('<img src=\"img/delete.png\"') != -1) {
					rareHTML = rareHTML.split('<img src=\"img/delete.png\"');
					resultHTML = rareHTML[0];
				}
				if(resultHTML.indexOf('<div style="z-index: 90;" ') != -1) {
					resultHTML = resultHTML.split('<div style="z-index: 90;" ')[0];
				} /**********************字体**********************/
				//字体
				var Bfont = elem.css("font");
				//字体颜色
				var fontSize = elem.css('font-size');
				//字体对齐方式
				var fontAlign = elem.css('text-align');
				//字体颜色
				var fontColor = elem.css('color');

				(Bfont == '') ? Bfont = "微软雅黑": Bfont;
				(fontSize == '') ? fontSize = '12': fontSize;
				(fontAlign == '') ? fontAlign = 'center': fontAlign;
				(fontColor == '') ? fontColor = 'rgb(0,0,0)': fontColor;

				/**********************物件**********************/
				//圆角
				var borderRadius = elem.css('borderRadius');
				var elemType = id.split('-')[0];
				(borderRadius == '') ? borderRadius = '0': borderRadius;
				//如果当前部件是圆角矩形,且borderRadius为空或者为0就把默认borderradius设置为4,下同
				(elemType == 'roundedRect' && (borderRadius == '' || borderRadius == '0')) ? borderRadius = '4': borderRadius;
				(elemType == 'circle' && (borderRadius == '' || borderRadius == '0')) ? borderRadius = '15': borderRadius;
				//填充
				var fillColor = elem.css('backgroundColor');
				(fillColor == '') ? fillColor = 'rgb(255,255,255)': fillColor;
				//渐近度
				var fillBlurRange = elem.css('boxShadow'); //rgb(0, 0, 0) 10px 10px 17px 20px inset
				var fillBlurSplit = fillBlurRange.split(' ');
				(fillBlurRange == '') ? fillBlurRange = '0': fillBlurRange = fillBlurSplit[5];
				//渐近色
				var fillBlurColor = fillBlurSplit[0] + fillBlurSplit[1] + fillBlurSplit[2];
				//线框样式
				var borderStyle = elem.css('border-left-style');
				(borderStyle == '') ? borderStyle = 'solid': borderStyle;
				//线框宽度
				var borderWidth = elem.css('border-left-width');
				(borderWidth == '') ? borderWidth = '2': borderWidth.split('px')[0];
				//线框颜色
				var borderColor = elem.css('border-left-color');
				(borderColor == '') ? borderColor = 'rgb(136,242,75)': borderColor;

				//阴影数据
				var shadow = elem.css('box-shadow');

				//字体样式数据
				var fontStyle = elem.css('fontStyle');
				var fontWeight = elem.css('fontWeight');
				var fontUnderline = elem.css('textDecoration');

				//文字高度
				var lineHeight = elem.css('line-height');

				blocks.push({
					BlockId: elem.attr('id'),
					BlockContent: resultHTML,
					BlockX: parseInt(elem.css("left"), 10),
					BlockY: parseInt(elem.css("top"), 10),
					BlockWidth: parseInt(elem.css("width"), 10),
					BlockHeight: parseInt(elem.css("height"), 10),
					BlockFont: Bfont,
					BlockFontSize: fontSize,
					BlockFontAlign: fontAlign,
					BlockFontColor: fontColor,
					BlockBorderRadius: borderRadius,
					BlockBackground: fillColor,
					BlockFillBlurRange: fillBlurRange,
					BlockFillBlurColor: fillBlurColor,
					BlockBorderStyle: borderStyle,
					BlockBorderWidth: borderWidth,
					BlockborderColor: borderColor,
					BlockShadow: shadow,
					BlockFontStyle: fontStyle,
					BlockFontWeight: fontWeight,
					BlockFontUnderline: fontUnderline,
					BlockLineHeight: lineHeight
				});

				var serliza = "{" + '"connects":' + JSON.stringify(connects) + ',"block":' + JSON.stringify(blocks) + "}";
				console.log(serliza);
				return serliza;
			}

			//点击事件
			function changeValue(id) {
				//双击修改文本
				$(id).dblclick(function() {
					var text = $(this).text();
					$(this).html("");
					$(this).append("<input class=\"chart-text-edit\" type=\"text\" value=\"" + text + "\" />");
					$(this).mouseleave(function() {
						$(this).html($(".chart-text-edit").val());
					});
				});
				//右键下拉菜单
				$(id).contextmenu(function() {
					rightMenu();
				});
			}

			//新增一个部件
			//参数newChartArea代表新增部件的区域
			//参数chartID代表新流程图部件的ID,格式为元素名称-index
			//参数left,top代表新部件的插入位置
			//参数blockName代表新部件的文本
			//参数undo表示是否进行撤销操作,如果进行撤销操作则不进行入栈,默认为false
			function addNewChart(newChartArea, chartID, left, top, blockName, undo) {

				undo = (undo == '') ? false : arguments[5];

				var name = chartID.split('-')[0];

				//在div内append元素
				$(newChartArea).append("<div class=\"draggable " + name + " new-" + name + "\" id=\"" + chartID + "\">" + blockName + "</div>");
				$("#" + chartID).css("left", left).css("top", top).css("position", "absolute").css("margin", "0px");

				//用jsPlumb添加锚点
				jsPlumb.addEndpoint(chartID, {
					anchors: "TopCenter"
				}, hollowCircle);
				jsPlumb.addEndpoint(chartID, {
					anchors: "RightMiddle"
				}, hollowCircle);
				jsPlumb.addEndpoint(chartID, {
					anchors: "BottomCenter"
				}, hollowCircle);
				jsPlumb.addEndpoint(chartID, {
					anchors: "LeftMiddle"
				}, hollowCircle);

				jsPlumb.draggable(chartID);
				$("#" + chartID).draggable({
					containment: "parent"
				}); //保证拖动不跨界

				sessionStorage['idIndex'] = sessionStorage['idIndex'] + 1;

				changeValue("#" + chartID);

				if(undo == false) {
					chartOperationStack['add'].push(getSingleChartJson(chartID));
					chartRareOperationStack.push('add');
				}
			}

			//通过json加载流程图
			function loadChartByJSON(data) {

				$("#chart-container").html(' ');

				var unpack = JSON.parse(data);

				if(!unpack) {
					return false;
				}

				for(var i = 0; i < unpack['block'].length; i++) {
					var BlockId = unpack['block'][i]['BlockId'];
					var BlockContent = unpack['block'][i]['BlockContent'];
					var BlockX = unpack['block'][i]['BlockX'];
					var BlockY = unpack['block'][i]['BlockY'];
					var width = unpack['block'][i]['BlockWidth'];
					var height = unpack['block'][i]['BlockHeight'];
					var font = unpack['block'][i]['BlockFont'];
					var fontSize = unpack['block'][i]['BlockFontSize'];
					var fontAlign = unpack['block'][i]['BlockFontAlign'];
					var fontColor = unpack['block'][i]['BlockFontColor'];
					var borderRadius = unpack['block'][i]['BlockBorderRadius'];
					var backgroundColor = unpack['block'][i]['BlockBackground'];
					var fillBlurRange = unpack['block'][i]['BlockFillBlurRange'];
					var fillBlurColor = unpack['block'][i]['BlockFillBlurColor'];
					var borderStyle = unpack['block'][i]['BlockBorderStyle'];
					var borderColor = unpack['block'][i]['BlockborderColor'];
					var shadow = unpack['block'][i]['BlockShadow'];
					var fontStyle = unpack['block'][i]['BlockFontStyle'];
					var fontWeight = unpack['block'][i]['BlockFontWeight'];
					var fontUnderline = unpack['block'][i]['BlockFontUnderline'];
					var lineHeight = unpack['block'][i]['BlockLineHeight'];

					var blockAttr = BlockId.split('-')[0];

					var boxInsetShadowStyle = '10px 10px ' + fillBlurRange + "px 20px " + fillBlurColor + ' inset';

					$('.chart-design').append("<div class=\"draggable " + blockAttr + " new-" + blockAttr + "\" id=\"" + BlockId + "\">" + BlockContent + "</div>");
					$("#" + BlockId)
						.css("left", BlockX)
						.css("top", BlockY)
						.css("position", "absolute")
						.css("margin", "0px")
						.css("width", width)
						.css("height", height)
						.css('font', font)
						.css('font-size', fontSize)
						.css('text-align', fontAlign)
						.css('color', fontColor)
						.css('border-radius', borderRadius)
						.css('background', backgroundColor)
						.css('box-shadow', boxInsetShadowStyle)
						.css('border-style', borderStyle)
						.css('border-color', borderColor)
						.css('box-shadow', shadow)
						.css('font-style', fontStyle)
						.css('font-weight', fontWeight)
						.css('font-underline', fontUnderline)
						.css('line-height', lineHeight);
					changeValue("#" + BlockId)
				}

				for(i = 0; i < unpack['connects'].length; i++) {

					var ConnectionId = unpack['connects'][i]['ConnectionId'];
					var PageSourceId = unpack['connects'][i]['PageSourceId'];
					var PageTargetId = unpack['connects'][i]['PageTargetId'];
					var PageSourceType = unpack['connects'][i]['PageSourceType'];
					var PageTargetType = unpack['connects'][i]['PageTargetType'];

					//用jsPlumb添加锚点
					jsPlumb.addEndpoint(PageSourceId, {
						anchors: "RightMiddle"
					}, hollowCircle);

					jsPlumb.addEndpoint(PageSourceId, {
						anchors: "LeftMiddle"
					}, hollowCircle);

					jsPlumb.addEndpoint(PageTargetId, {
						anchors: "RightMiddle"
					}, hollowCircle);

					jsPlumb.addEndpoint(PageTargetId, {
						anchors: "LeftMiddle"
					}, hollowCircle);

					jsPlumb.addEndpoint(PageSourceId, {
						anchors: "TopCenter"
					}, hollowCircle);

					jsPlumb.addEndpoint(PageSourceId, {
						anchors: "BottomCenter"
					}, hollowCircle);

					jsPlumb.addEndpoint(PageTargetId, {
						anchors: "TopCenter"
					}, hollowCircle);

					jsPlumb.addEndpoint(PageTargetId, {
						anchors: "BottomCenter"
					}, hollowCircle);

					jsPlumb.draggable(PageSourceId);
					jsPlumb.draggable(PageTargetId);

					$("#" + PageSourceId).draggable({
						containment: "parent"
					}); //保证拖动不跨界
					$("#" + PageTargetId).draggable({
						containment: "parent"
					}); //保证拖动不跨界

					var common = {
						anchors: [PageSourceType, PageTargetType],
						endpoints: ["Blank", "Blank"],
						label: unpack['connects'][i]['Connectiontext'],
						overlays: [
							["Arrow",{
								width: 20,
								length: 20,
								location: 1
							}]
						],
					};

					jsPlumb.connect({

						source: PageSourceId,
						target: PageTargetId,

					}, common);

				};

				$("._jsPlumb_overlay").click(function() {
					var text = $(this).text();
					$(this).html("");
					$(this).append("<input class=\"chart-text-edit\" type=\"text\" value=\"" + text + "\" />");
					$(this).mouseleave(function() {
						$(this).html($(".chart-text-edit").val());
					});
				})

				return true;
			}
			//重绘流程图(通过读取JSON数据重绘流程图)
			$("#creat_img").click(function() {
				loadChartByJSON('{"connects":[{"ConnectionId":"con_64","PageSourceId":"rect-01112","PageTargetId":"rect-0111114","Connectiontext":null,"PageSourceType":"BottomCenter","PageTargetType":"TopCenter"},{"ConnectionId":"con_68","PageSourceId":"rect-0111114","PageTargetId":"rect-011111116","Connectiontext":null,"PageSourceType":"LeftMiddle","PageTargetType":"RightMiddle"},{"ConnectionId":"con_85","PageSourceId":"rect-010","PageTargetId":"rect-01112","Connectiontext":"开始","PageSourceType":"RightMiddle","PageTargetType":"LeftMiddle"},{"ConnectionId":"con_91","PageSourceId":"rect-011111116","PageTargetId":"rect-01111111118","Connectiontext":"结束","PageSourceType":"LeftMiddle","PageTargetType":"TopCenter"}],"block":[{"BlockId":"rect-010","BlockContent":"讨论需求","BlockX":154,"BlockY":79,"BlockWidth":120,"BlockHeight":20,"BlockFont":"normal normal 400 normal 12px / normal arial","BlockFontSize":"12px","BlockFontAlign":"center","BlockFontColor":"rgb(0, 0, 0)","BlockBorderRadius":"0px","BlockBackground":"rgb(255, 255, 255)","BlockFillBlurColor":"noneundefinedundefined","BlockBorderStyle":"solid","BlockBorderWidth":"2px","BlockborderColor":"rgb(232, 84, 39)","BlockShadow":"none","BlockFontStyle":"normal","BlockFontWeight":"400","BlockFontUnderline":"none solid rgb(0, 0, 0)","BlockLineHeight":"normal"},{"BlockId":"rect-01112","BlockContent":"制定方案","BlockX":499,"BlockY":78,"BlockWidth":120,"BlockHeight":20,"BlockFont":"normal normal 400 normal 12px / normal arial","BlockFontSize":"12px","BlockFontAlign":"center","BlockFontColor":"rgb(0, 0, 0)","BlockBorderRadius":"0px","BlockBackground":"rgb(255, 255, 255)","BlockFillBlurColor":"noneundefinedundefined","BlockBorderStyle":"solid","BlockBorderWidth":"2px","BlockborderColor":"rgb(232, 84, 39)","BlockShadow":"none","BlockFontStyle":"normal","BlockFontWeight":"400","BlockFontUnderline":"none solid rgb(0, 0, 0)","BlockLineHeight":"normal"},{"BlockId":"rect-0111114","BlockContent":"程序开发","BlockX":622,"BlockY":331,"BlockWidth":120,"BlockHeight":20,"BlockFont":"normal normal 400 normal 12px / normal arial","BlockFontSize":"12px","BlockFontAlign":"center","BlockFontColor":"rgb(0, 0, 0)","BlockBorderRadius":"0px","BlockBackground":"rgb(255, 255, 255)","BlockFillBlurColor":"noneundefinedundefined","BlockBorderStyle":"solid","BlockBorderWidth":"2px","BlockborderColor":"rgb(232, 84, 39)","BlockShadow":"none","BlockFontStyle":"normal","BlockFontWeight":"400","BlockFontUnderline":"none solid rgb(0, 0, 0)","BlockLineHeight":"normal"},{"BlockId":"rect-011111116","BlockContent":"发布上线","BlockX":176,"BlockY":243,"BlockWidth":120,"BlockHeight":20,"BlockFont":"normal normal 400 normal 12px / normal arial","BlockFontSize":"12px","BlockFontAlign":"center","BlockFontColor":"rgb(0, 0, 0)","BlockBorderRadius":"0px","BlockBackground":"rgb(255, 255, 255)","BlockFillBlurColor":"noneundefinedundefined","BlockBorderStyle":"solid","BlockBorderWidth":"2px","BlockborderColor":"rgb(232, 84, 39)","BlockShadow":"none","BlockFontStyle":"normal","BlockFontWeight":"400","BlockFontUnderline":"none solid rgb(0, 0, 0)","BlockLineHeight":"normal"},{"BlockId":"rect-01111111118","BlockContent":"结束","BlockX":200,"BlockY":447,"BlockWidth":120,"BlockHeight":20,"BlockFont":"normal normal 400 normal 12px / normal arial","BlockFontSize":"12px","BlockFontAlign":"center","BlockFontColor":"rgb(0, 0, 0)","BlockBorderRadius":"0px","BlockBackground":"rgb(255, 255, 255)","BlockFillBlurColor":"noneundefinedundefined","BlockBorderStyle":"solid","BlockBorderWidth":"2px","BlockborderColor":"rgb(232, 84, 39)","BlockShadow":"none","BlockFontStyle":"normal","BlockFontWeight":"400","BlockFontUnderline":"none solid rgb(0, 0, 0)","BlockLineHeight":"normal"}]}');

			});

			//删除一个流程框图,若参数undo为true则在进行操作时不进行入栈操作,默认为false
			function deleteChart(id, undo) {
				undo = (undo == '') ? false : '';
				var DOM = $('#' + id);
				if(undo == false) {
					chartOperationStack['delete'].push(getSingleChartJson(id));
				}
				jsPlumb.removeAllEndpoints(id);
				DOM.remove();
				if(undo == false) {
					chartRareOperationStack.push('delete');
				}
			}

			//设置流程框图宽度,如果当前选择的部件为none则默认改变全局,下同
			function setChartDesignWidth(width) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('width', width);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('width', width);
				}
			}

			//设置流程框图高度
			function setChartDesignHeight(height) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('height', height);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('height', height);
				}
			}

			//设置流程框图top
			function setChartDesignTop(top) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('top', top);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('top', top);
				}
			}

			//设置流程框图left
			function setChartDesignLeft(left) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('left', left);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('left', left);
				}
			}

			//设置流程框图字体
			function setChartDesignFont(font) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('font', font);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('font', font);
				}
			}

			//设置流程框图字体大小
			function setChartDesignFontSize(size) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('font-size', size);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('font-size', size);
				}
			}

			//设置流程框图字体颜色
			function setChartDesignFontColor(color) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('color', color);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('color', color);
				}
			}

			//设置流程图框的对齐方式
			function setChartDesignFontAlign(align) {
				var lign = {
					'居左': 'left',
					'居右': 'right',
					'居中': 'center'
				};
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('text-align', lign[align]);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('text-align', lign[align]);
				}
			}

			//设置流程图框的圆角大小
			function setChartDesignBorderRadius(radius) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('border-top-left-radius', radius);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('border-top-left-radius', radius);
				}
			}

			//设置流程图框的线样式
			//参数style只能为solid|dotted|double|dashed
			function setChartDeignBorderLineStyle(style) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('border-style', style);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('border-style', style);
				}
			}

			//设置流程图框的线宽度
			function setChartDesignBorderWidthStyle(style) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('border-width', style);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('border-width', style);
				}
			}

			//设置流程图框的线颜色
			function setChartDesignBorderColorStyle(style) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('border-color', style);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('border-color', style);
				}
			}

			//设置流程图框背景色
			function setChartDesignBackground(style) {
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('backgroundColor', style);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('backgroundColor', style);
				}
			}

			//设置流程图框渐近色,参数rate表示渐近度,blurColor表示渐近色
			function setChartDesignBoxShadow(rate, blurColor) {
				var style = '10px 10px ' + rate + "px 20px " + blurColor + ' inset';
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('box-shadow', style);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('box-shadow', style);
				}
			}

			//设置流程图框阴影
			//参数h表示水平阴影
			//参数v表示垂直阴影
			//参数blur表示模糊距离
			//参数spread表示阴影尺寸
			//参数color表示阴影颜色
			function setChartDesignBoxShadowA(h, v, blur, spread, color) {
				var style = h + 'px ' + v + 'px ' + blur + 'px ' + spread + 'px ' + color;
				if(sessionStorage['currentChartSelected'] == 'none') {
					$('.new-circle,.new-rhombus,.new-roundedRect,.new-rect').css('box-shadow', style);
				} else {
					$('#' + sessionStorage['currentChartSelected']).css('box-shadow', style);
				}
			}

			//设置文字高度
			function setChartDesignLineHeight(height) {
				$('#' + sessionStorage['currentChartSelected']).css('line-height', height);
			}

			//设置文字间距
			function setChartDesignLetterSpacing(space) {
				$('#' + sessionStorage['currentChartSelected']).css('letter-spacing', space);
			}

			//*********************************流程图数据操作区域*********************************

			$(document).ready(function() {

				//**************************************UI控制部分***************************************

				//初始化动画效果
				$('.chart-ratio-form,.chart-fill-border-selector,#chart-v-shadow-display,#chart-h-shadow-display,#chart-blur-range-display,#chart-shadow-blur-display,#chart-shadow-color-display,#chart-shadow-spread-display').css("opacity", '0.6');

				//隐藏右侧属性面板
				//$('.chart-right-panel').hide();

				//为按钮,列表添加动画效果
				$('.fl-btn,h4').hover(
					function() {
						$(this).stop().animate({
							opacity: 0.5
						}, 'fast');
					},
					function() {
						$(this).stop().animate({
							opacity: 1
						}, 'fast');
					}
				);

				//为左下角大小调节添加动画效果
				$('.chart-ratio-form,.chart-fill-border-selector,#chart-v-shadow-display,#chart-h-shadow-display,#chart-blur-range-display,#chart-shadow-blur-display,#chart-shadow-color-display,#chart-shadow-spread-display').hover(
					function() {
						$(this).stop().animate({
							opacity: 1
						}, 'fast');
					},
					function() {
						$(this).stop().animate({
							opacity: 0.6
						}, 'fast');
					}
				);

				//给左侧工具栏分页
				$(".chart-object").accordion();

				//调节区域双击可输入数字更改
				$('.rare-ratio').dblclick(function() {
					var chartRatioValue = document.getElementById('rear-ratio').value;
				});

				//页面上方按钮事件

				//标识线条选择器有没有被展开,默认不展开
				sessionStorage['topLineSelectIsDisplayed'] = false;
				//标识排列选择器有没有被展开,默认不展开
				sessionStorage['topAlignSelectIsDisplayed'] = false;

				//对页面上方的工具菜单进行折叠
				function selectorToggle(event, element) {
					//取消事件冒泡
					event.stopPropagation();
					//设置弹出层的位置
					var offset = $(event.target).offset();
					$(element).css({
						top: offset.top + $(event.target).height() + "px",
						left: offset.left
					});

					//按钮的toggle,如果div是可见的,点击按钮切换为隐藏的;如果是隐藏的,切换为可见的。  
					$(element).toggle('fast');
				}
				//上方工具栏的按钮点击事件
				$('.fl-btn').click(function(event) {
					//取被点击按钮的ID
					var flBtnID = $(this).attr('id');
					var currentListFlag = getChartRightListFlag(); //当前显示的属性面板
					switch(flBtnID) {
						case 'new-box':
							//新建流程图框
							if(sessionStorage['midIsOccupied'] == 'not') {
								//如果中间位置没有被占据则在中间位置新建一个部件
								var left = $('.chart-design').width() / 2;
								var top = $('.chart-design').height() / 2;
								addNewChart('.chart-design', "roundedRect-" + sessionStorage['idIndex'] + sessionStorage['currentChartAmount'], left, top - 20, '新部件');
								sessionStorage['midIsOccupied'] = 'yes';
								sessionStorage['currentChartAmount'] = sessionStorage['currentChartAmount'] + 2;
							} else {
								//如果中间位置被占据则根据随机数新建一个部件
								var randomLeft = Math.ceil(Math.random() * $('.chart-design').width());
								var randomTop = Math.ceil(Math.random() * ($('.chart-design').height() - 25));
								addNewChart('.chart-design', "roundedRect-" + sessionStorage['idIndex'] + sessionStorage['currentChartAmount'], randomLeft, randomTop, '新部件');
								sessionStorage['currentChartAmount'] = sessionStorage['currentChartAmount'] + 2;
							}
							break;
						case 'line-mode':
							//设置线条样式
							if(sessionStorage['topAlignSelectIsDisplayed'] == 'true') {
								$('#align-select-div').toggle('fast');
								$('#text-select-div').toggle('fast');
								sessionStorage['topAlignSelectIsDisplayed'] = false;
							}
							selectorToggle(event, '#line-select-div');
							sessionStorage['topLineSelectIsDisplayed'] = true;
							break;
						case 'text-chart-align':
							//流程图框对齐或文本对齐
							if(sessionStorage['topLineSelectIsDisplayed'] == 'true') {
								$('#line-select-div').toggle('fast');
								sessionStorage['topLineSelectIsDisplayed'] = false;
							}
							selectorToggle(event, '#align-select-div');
							sessionStorage['topAlignSelectIsDisplayed'] = true;
							break;
						case 'text-font-style':
							//文字样式
							if(sessionStorage['topLineSelectIsDisplayed'] == 'true') {
								$('#line-select-div').toggle('fast');
								$('#align-select-div').toggle('fast');
								sessionStorage['topLineSelectIsDisplayed'] = false;
							}
							selectorToggle(event, '#text-select-div');
							sessionStorage['topAlignSelectIsDisplayed'] = true;
							break;
						case 'border-selector-style':
							//流程图边框颜色
							if(sessionStorage['topLineSelectIsDisplayed'] == 'true') {
								$('#line-select-div').toggle('fast');
								$('#align-select-div').toggle('fast');
								$('#text-select-div').toggle('fast');
								sessionStorage['topLineSelectIsDisplayed'] = false;
							}
							selectorToggle(event, '#border-selector-div');
							sessionStorage['topAlignSelectIsDisplayed'] = true;
							break;
						case 'chart-save':
							//分享或保存(生成JSON)
							var jsondata = save();
							$('.save-form').slideToggle('slow');
							$('#save-json-form-display').html(jsondata);
							html2canvas($('.droppable'), {
								onrendered: function(canvas) {
									var data = canvas.toDataURL("image/png");
									console.log('<a href="' + data + '">Download</a>');
									$('.save-img-href').html('<a href="' + data + '">Download</a>');
								}
							});
							break;
						case 'btn-object':
							//显示object面板
							attrToggle('object', currentListFlag);
							break;
						case 'btn-text':
							//显示text面板
							attrToggle('text', currentListFlag);
							break;
						case 'btn-style':
							//显示style面板`
							attrToggle('style', currentListFlag);
							break;
						case 'btn-align-left':
							//居左显示
							setChartTextAlign(sessionStorage['currentChartSelected'], 'left');
							$('#btn-align-left').addClass('fl-align-style-active');
							$('#btn-align-right,#btn-align-center,#btn-align-none').removeClass('fl-align-style-active');
							break;
						case 'btn-align-right':
							//居右显示
							setChartTextAlign(sessionStorage['currentChartSelected'], 'right');
							$('#btn-align-right').addClass('fl-align-style-active');
							$('#btn-align-left,#btn-align-center,#btn-align-none').removeClass('fl-align-style-active');
							break;
						case 'btn-align-center':
							//居中显示
							setChartTextAlign(sessionStorage['currentChartSelected'], 'center');
							$('#btn-align-center').addClass('fl-align-style-active');
							$('#btn-align-right,#btn-align-left,#btn-align-none').removeClass('fl-align-style-active');
							break;
						case 'btn-align-none':
							//居无显示
							setChartTextAlign(sessionStorage['currentChartSelected'], 'left');
							$('#btn-align-none').addClass('fl-align-style-active');
							$('#btn-align-right,#btn-align-center,#btn-align-left').removeClass('fl-align-style-active');
							break;
						default:
							break;
					}
				});

				//切换字体样式按钮状态
				function fontStyleBtnToggle(will) {
					$('#' + will).toggleClass('fl-font-style-active');
				}
				//字体样式按钮控制区域
				$('.fl-font-style').click(function() {
					var id = $(this).attr('id');
					switch(id) {
						case 'B': //bold
							fontStyleBtnToggle('B');
							$('#' + sessionStorage['currentChartSelected']).toggleClass("fl-font-style-bold");
							break;
						case 'I': //italic
							fontStyleBtnToggle('I');
							$('#' + sessionStorage['currentChartSelected']).toggleClass("fl-font-style-italic");
							break;
						case 'U': //underline
							fontStyleBtnToggle('U');
							$('#' + sessionStorage['currentChartSelected']).toggleClass("fl-font-style-underline");
							break;
						default:
							break;
					}
				});

				//**************************************UI控制部分***************************************

				//***********************************元素拖动控制部分************************************

				//允许元素拖动
				$(".list-content .area").children().draggable({
					//revert: "valid",//拖动之后原路返回
					helper: "clone", //复制自身
					scope: "dragflag" //标识
				});
				var index = -1;
				$(".droppable").droppable({
					accept: ".draggable", //只接受来自类.dragable的元素
					activeClass: "drop-active", //开始拖动时放置区域显示
					scope: "dragflag",
					drop: function(event, ui) {

						sessionStorage['idIndex'] = sessionStorage['idIndex'] + 1;

						//获取鼠标坐标
						var left = parseInt(ui.offset.left - $(this).offset().left);
						var top = parseInt(ui.offset.top - $(this).offset().top) + 4;

						setChartLocation(top, left); //设置坐标

						var name = ui.draggable[0].id; //返回被拖动元素的ID
						var trueId = name + "-" + sessionStorage['idIndex'] + sessionStorage['currentChartAmount'];

						//在div内append元素
						$(this).append("<div class=\"draggable " + name + " new-" + name + "\" id=\"" + trueId + "\">" + $(ui.helper).html() + "</div>");
						$("#" + trueId).css("left", left).css("top", top).css("position", "absolute").css("margin", "0px");

						//用jsPlumb添加锚点

						jsPlumb.addEndpoint(trueId, {
							anchors: "RightMiddle"
						}, hollowCircle);

						jsPlumb.addEndpoint(trueId, {
							anchors: "LeftMiddle"
						}, hollowCircle);

						jsPlumb.addEndpoint(trueId, {
							anchors: "TopCenter"
						}, hollowCircle);

						jsPlumb.addEndpoint(trueId, {
							anchors: "BottomCenter"
						}, hollowCircle);

						jsPlumb.draggable(trueId);
						$("#" + trueId).draggable({
							containment: "parent"
						}); //保证拖动不跨界

						changeValue("#" + trueId);

						list = jsPlumb.getAllConnections(); //获取所有的连接

						sessionStorage['idIndex'] = sessionStorage['idIndex'] + 1;
						//设置当前选择的流程框图
						sessionStorage['currentChartSelected'] = trueId;

						//将新拖进来的流程图框JSON数据push进栈
						chartOperationStack['add'].push(getSingleChartJson(trueId));
						chartRareOperationStack.push('add');

						sessionStorage['currentChartAmount'] = parseInt(sessionStorage['currentChartAmount'], 10) + 2;
					}
				});

				$('.droppable .draggable').resizable({
					ghost: true
				});

				//删除元素按钮
				$(".droppable").on("mouseenter", ".draggable", function() {
					$(this).append("<img src=\"img\/delete.png\" id=\"fuck\" style=\"position:absolute;width:20px;height:16px;\"/>");

					//因为流程图的形状不一样,所以要获取特定的流程图名称来指定删除按钮的位置
					var wholeID = $(this).attr('id');
					var wholeIDSep = wholeID.split('-');

					if(wholeIDSep[0] == "circle") {
						$("img").css("left", $(this).width() - 20).css("top", 20);
					} else if(wholeIDSep[0] == "rhombus") {
						$("img").css("left", $(this).width() - 18).css("top", 10);
					} else {
						$("img").css("left", $(this).width() - 20).css("top", 10);
					}
				});

				$(".droppable").on("mouseleave", ".draggable", function() {
					$("img").remove();
				});

				$(".droppable").on("click", "img", function() {
					//要先保存父元素的DOM,因为出现确认对话框之后(this)会消失
					var parentDOM = $(this).parent();
					var parentID = parentDOM.attr('id');
					if(confirm("确定要删除吗?")) {
						chartOperationStack['delete'].push(getSingleChartJson(parentID));
						jsPlumb.removeAllEndpoints(parentID);
						parentDOM.remove();
						chartRareOperationStack.push('delete');
					}
				});

				//设计区域元素被点击事件,同步右侧属性面板
				$('.droppable').on('click', '.draggable', function() {
					//获得当前选择部件的ID
					sessionStorage['currentChartSelected'] = $(this).attr('id');

					//设置当前部件的坐标和大小
					setChartLocation($(this).offset().top, $(this).offset().left);
					setChartSize($(this).width(), $(this).height());

					//设置当前选择部件的字体
					setChartFont(getChartFont());

					//设置当前选择部件的字体大小
					setChartFontSize(getChartFontSize());

					//设置当前选择部件的对齐方式
					setChartAlign(getChartAlign());

					//设置当前选择部件的字体颜色
					setChartFontColor(getChartFontColor());

					//设置JSON数据放置区域的值
					setChartJson2Box(getSingleChartJson(sessionStorage['currentChartSelected']));

					//设置圆角
					setChartBorderRadius(getChartBorderRadius());

					//设置border属性width style color
					setChartBorderLineStyle(getChartBorderLineStyle());
					setChartBorderWidthStyle(getChartBorderWidthStyle());
					setChartBorderColorStyle(getChartBorderColorStyle());

					//设置背景色
					setChartBackgroundColor(getChartBackgroundColor());

					//设置渐近度和渐近色
					setChartBlurRange(getChartBlurRange());
					setChartBlurColor(getChartBlurColor());

					//设置当前部件的阴影
					setChartHShadow(getChartHShadow());
					setChartVShadow(getChartVshadow());
					setChartShadowSpread(getChartShadowSpread());
					setChartShadowColor(getChartShadowColor());
					setChartShadowBlur(getChartShadowBlur());

					//设置字体样式
					setChartFontStyleBtn(getChartFontStyle(sessionStorage['currentChartSelected']));

					//设置文字高度
					setChartLineHeight(getChartLineHeight());

					//设置文字间距
					setChartLetterSpacing(getChartLetterSpacing());
				});

				//设计区域被双击时
				$('.droppable').on('dblclick', function() {
					sessionStorage['currentChartSelected'] = 'none'; //置当前选择的流程图框为空
					$('#B,#I,#U').removeClass('fl-font-style-active'); //置当前字体样式选择器为空
					$('#btn-align-center,#btn-align-left,#btn-align-right,#btn-align-none').removeClass('fl-align-style-active'); //置当前对齐方式为空
				});

				//页面顶部工具栏选择事件
				$('.line-select').on('click', '.top-menu-selector', function() {
					var idSelected = $(this).attr('id').split('-');
					if(idSelected[0] == 'line') {
						setChartLineType(idSelected[1]);
					} else if(idSelected[0] == 'align') {
						if(sessionStorage['currentChartSelected'] != 'none') {
							setChartTextAlign(sessionStorage['currentChartSelected'], idSelected[1]);
						} else {
							setChartTextAlign('', idSelected[1]);
						}

					}
				});

				//设计区域元素被拖动时,触发同步坐标
				/*$(".droppable").droppable({
				  activate:function(event,ui){
				    console.log('sdsd');
				    //console.log(this);
				    setChartLocation($(this).offset().top,$(this).offset().left);
				  }
				});*/

				$(".draggable").draggable({
					start: function() {
						console.log('start');
					},
					drag: function() {
						console.log('drag');
					},
					stop: function() {
						console.log('stop');
					}
				});

				//*****************右侧属性面板内容改变同步到设计区域******************

				////////预加载
				jQuery(function($) {
					txtValue = $(".chart-location-form").val();
					////////    给txtbox绑定键盘事件
					$(".chart-location-form").bind("keydown", function() {
						var currentValue = $(this).val();
						var currentID = $(this).attr('id');
						if(currentValue != txtValue) {
							switch(currentID) {
								case 'chart-font-display': //字体
									setChartDesignFont(currentValue);
									break;
								case 'chart-font-size-display': //字体大小
									setChartDesignFontSize(currentValue * 10);
									break;
								case 'chart-align-display': //字体对齐样式
									setChartDesignFontAlign(currentValue);
									break;
								case 'chart-font-color-display': //字体颜色
									setChartDesignFontColor(currentValue);
									break;
								case 'lo-x-display': //top
									setChartDesignTop(currentValue * 10);
									break;
								case 'lo-y-display': //left
									setChartDesignLeft(currentValue * 10);
									break;
								case 'chart-width-display': //宽度
									setChartDesignWidth(currentValue * 10);
									break;
								case 'chart-height-display': //高度
									setChartDesignHeight(currentValue * 10);
									break;
								case 'chart-border-display': //框线style
									setChartDesignBorderRadius(currentValue);
									break;
								case 'chart-fill-border-width-display': //框线粗细
									setChartDesignBorderWidthStyle(currentValue);
									break;
								case 'chart-fill-border-color-display': //框线颜色
									setChartDesignBorderColorStyle(currentValue);
									break;
								case 'chart-font-height-display': //文字高度
									setChartDesignLineHeight(currentValue);
									break;
								case 'chart-font-height-display': //文字间距
									setChartDesignLetterSpacing(currentValue);
									break;
								default:
									break;
							}
						}
					});
				});

				//选择框的选择项被改变时触发
				$('.chart-fill-border-selector').change(function() {
					var valSelected = $(this).children('option:selected').val(); //selected的值
					setChartDeignBorderLineStyle(valSelected);
				})

				//线条颜色选择器值被改变时触发
				$('#chart-fill-border-color-display').change(function() {
					setChartDesignBorderColorStyle($(this).val());
				});

				//字体颜色选择器值被改变时触发
				$('#chart-font-color-display').change(function() {
					setChartDesignFontColor($(this).val());
				});

				//背景颜色选择器值被改变时触发
				$('#chart-background-color-display').change(function() {
					setChartDesignBackground($(this).val());
				});

				//渐近度被改变时触发
				$('#chart-blur-range-display').change(function() {
					var chartblurDom = document.getElementById('chart-blur-range-display');
					setChartDesignBoxShadow(chartblurDom.value, getChartBlurColorByColorSelector());
				});

				//同步设计区域的流程图框阴影
				function synChartShadowInDesign() {
					h = getChartHShadowBySelector();
					v = getChartVShadowBySelector();
					blur = getChartShadowBlurBySelector();
					spread = getChartShadowSpreadBySelector();
					color = getChartShadowColorBySelector();
					setChartDesignBoxShadowA(h, v, blur, spread, color);
				} //垂直阴影改变时触发
				$('#chart-h-shadow-display').change(function() {
					synChartShadowInDesign();
				});

				//水平阴影改变时触发
				$('#chart-v-shadow-display').change(function() {
					synChartShadowInDesign();
				});

				//模糊距离改变时触发
				$('#chart-shadow-blur-display').change(function() {
					synChartShadowInDesign();
				});

				//阴影尺寸改变时触发
				$('#chart-shadow-spread-display').change(function() {
					synChartShadowInDesign();
				});

				//阴影颜色选择器改变时触发
				$('#chart-shadow-color-display').change(function() {
					synChartShadowInDesign();
				});

				////目标选择框文本发生更改时触发的事件,根据ID不同

				//$(".chart-fill-border-selector option:selected").attr('value')

				//*****************右侧属性面板内容改变同步到设计区域******************

				//删除连接线

				//DOCUMENT快捷键操作
				$(document).on("keydown", function(event) {
					if(event.ctrlKey && event.which == 90) {
						//按下 CTRL+Z 进行撤销操作
						var rareOperation = chartRareOperationStack.pop(); //取出用户最近一次的操作
						var operationJSON = chartOperationStack[rareOperation].pop(); //根据用户最后一次进行的操作弹出最近一次的流程框图数据
						operationJSON = JSON.parse(operationJSON);
						var chartOperationData = operationJSON['block'][0];
						switch(rareOperation) {
							case 'delete':
								//用户操作为删除,撤销操作为添加
								addNewChart('.chart-design', chartOperationData['BlockId'] + sessionStorage['idIndex'] + sessionStorage['currentChartAmount'], chartOperationData['BlockX'], chartOperationData['BlockY'], chartOperationData['BlockContent'], true);
								break;
							case 'add':
								//用户操作为添加,撤销操作为删除
								deleteChart(chartOperationData['BlockId'], true);
								break;
							case 'paste':
								//用户操作为粘贴,撤销操作为删除
								deleteChart(chartOperationData['BlockId'], true);
								break;
						}
					}
					if(event.ctrlKey && event.which == 67) {
						//CTRL+C 进行复制部件操作
						if(sessionStorage['currentChartSelected'] != 'none') {
							chartOperationStack['copy'].push(getSingleChartJson(sessionStorage['currentChartSelected']));
							//console.log(sessionStorage['currentChartSelected']);
							chartRareOperationStack.push('copy');
						}
					}
					if(event.ctrlKey && event.which == 86) {
						//CTRL+V 进行粘贴部件操作
						var chartCopiedJson = chartOperationStack['copy'][chartOperationStack['copy'].length - 1];

						var unpack = JSON.parse(chartCopiedJson);
						var chartBlockObj = unpack['block'][0];
						var chartPastedID = chartBlockObj['BlockId'] + sessionStorage['idIndex']; //设置被粘贴部件的新ID

						var BlockContent = chartBlockObj['BlockContent'];
						var BlockX = chartBlockObj['BlockX'];
						var BlockY = chartBlockObj['BlockY'];
						var width = chartBlockObj['BlockWidth'];
						var height = chartBlockObj['BlockHeight'];
						var font = chartBlockObj['BlockFont'];
						var fontSize = chartBlockObj['BlockFontSize'];
						var fontAlign = chartBlockObj['BlockFontAlign'];
						var fontColor = chartBlockObj['BlockFontColor'];
						var borderRadius = chartBlockObj['BlockBorderRadius'];
						var backgroundColor = chartBlockObj['BlockBackground'];
						var fillBlurRange = chartBlockObj['BlockFillBlurRange'];
						var fillBlurColor = chartBlockObj['BlockFillBlurColor'];
						var borderStyle = chartBlockObj['BlockBorderStyle'];
						var borderColor = chartBlockObj['BlockborderColor'];
						var shadow = chartBlockObj['BlockShadow'];
						var fontStyle = chartBlockObj['BlockFontStyle'];
						var fontWeight = chartBlockObj['BlockFontWeight'];
						var fontUnderline = chartBlockObj['BlockFontUnderline'];
						var lineHeight = chartBlockObj['BlockLineHeight'];

						var blockAttr = chartPastedID.split('-')[0];

						var boxInsetShadowStyle = '10px 10px ' + fillBlurRange + "px 20px " + fillBlurColor + ' inset';

						if(unpack['connects'].length == 0) {
							addNewChart('.chart-design', chartPastedID, chartBlockObj['BlockX'], chartBlockObj['BlockY'] - 20, chartBlockObj['BlockContent']);
							$("#" + chartPastedID)
								.css("left", BlockX)
								.css("top", BlockY)
								.css("position", "absolute")
								.css("margin", "0px")
								.css("width", width)
								.css("height", height)
								.css('font', font)
								.css('font-size', fontSize)
								.css('text-align', fontAlign)
								.css('color', fontColor)
								.css('border-radius', borderRadius)
								.css('background', backgroundColor)
								.css('box-shadow', boxInsetShadowStyle)
								.css('border-style', borderStyle)
								.css('border-color', borderColor)
								.css('box-shadow', shadow)
								.css('font-style', fontStyle)
								.css('font-weight', fontWeight)
								.css('font-underline', fontUnderline)
								.css('line-height', lineHeight);
						} else {

						}
						unpack['block'][0]['BlockId'] = chartPastedID;
						chartOperationStack['paste'].push(JSON.stringify(unpack));
						chartRareOperationStack.push('paste');
					}
					if(event.which == 46) {
						//DELETE 进行删除部件操作
						if(sessionStorage['currentChartSelected'] != 'none') {
							if(confirm("确定要删除吗?")) {
								deleteChart(sessionStorage['currentChartSelected']);
								setChartLocation(0, 0);
								setChartSize(0, 0);
							}
						}
					}
				});

				//点击空白处或者自身隐藏弹出层，下面分别为滑动和淡出效果。  
				$(document).click(function(event) {
					$('.line-select').slideUp('fast');
					sessionStorage['topLineSelectIsDisplayed'] = false;
					sessionStorage['topAlignSelectIsDisplayed'] = false;
				});

				//设置style
				function setEnvironmentStyle(styleName) {
					switch(styleName) {
						case 'blue':
							console.log(styleName);
							$('.droppable').css('background', 'rgb(173,219,225)');
							break;
						case 'white':
							$('.droppable').css('background', 'rgb(255,255,255)');
							break;
						case 'pink':
							$('.droppable').css('background', 'rgb(255,235,190)');
							break;
						case 'dark':
							$('.droppable').css('background', 'rgb(6,1,0)');
							break;
						case 'purple':
							$('.droppable').css('background', 'rgb(127,0,185)');
							break;
					}
				} //选择相应的style
				$('.right-style-selector').click(function() {
					var styleName = $(this).attr('id');
					setEnvironmentStyle(styleName);
				});

				//***********************************元素拖动控制部分************************************

				//***********************************元素拖动控制部分************************************

				$(".save-heading span").click(function() {
					$('.save-form').slideToggle('slow');
				})

			});
			//设置右键下拉菜单
			function rightMenu() {
				//获取我们自定义的右键菜单
				var menu = document.querySelector("#menu");

				window.oncontextmenu = function(e) {
					var e = e || window.event;

					if(e.srcElement.id == "chart-container") {
						return;
					}
					//取消默认的浏览器自带右键 很重要！！
					e.preventDefault();

					//根据事件对象中鼠标点击的位置，进行定位
					menu.style.left = e.clientX + 'px';
					menu.style.top = e.clientY + 'px';

					//改变自定义菜单的宽，让它显示出来
					menu.style.width = '125px';
				}
				//关闭右键菜单，很简单
				window.onclick = function(e) {
					//用户触发click事件就可以关闭了，因为绑定在window上，按事件冒泡处理，不会影响菜单的功能
					document.querySelector('#menu').style.height = 0;
				}
			}
			//下拉菜单按钮事件
			function menu_operate() {
				alert("点击了功能点1，可以进行操作了，这里主要是提供菜单按钮使用的方法");
			}
		</script>
		<script>
			$(".cancalline").click(function() {
				$(".fuchuang").css({
					"display": "none"
				});
			})
			//双击事件
			jsPlumb.bind("dblclick", function(conn, originalEvent) {
				$(".fuchuang").css({
					"display": "block"
				});
				var aaa = conn.sourceId;
				var bbb = conn.targetId;
				var PageSourceType = conn.endpoints[0].anchor.type;
				var PageTargetType = conn.endpoints[1].anchor.type;
				jsPlumb.detach(conn);

				$('.sureaaa').unbind("click");
				$(".sureaaa").click(function() {
					var PageSourceId = aaa;
					var PageTargetId = bbb;
					var innercont = $(".inputcont").val();
					var common = {
						anchors: [PageSourceType, PageTargetType],
						endpoints: ["Blank", "Blank"],
						label: innercont,
						cssClass: PageSourceId + PageTargetId,
						overlays: [
							["Arrow",{
								width: 20,
								length: 20,
								location: 1
							}]
						],
					};

					jsPlumb.connect({
						source: PageSourceId,
						target: PageTargetId,
					}, common);

					$("." + PageSourceId + PageTargetId).next().html(innercont)
					$(".fuchuang").css({
						"display": "none"
					});

				})
				sessionStorage['currentChartAmount'] = sessionStorage['currentChartAmount'] + 2;

			});
			//右键下拉菜单
			jsPlumb.bind("contextmenu", function(conn, originalEvent) {
				$(".fuchuang").css({
					"display": "block"
				});
				var aaa = conn.sourceId;
				var bbb = conn.targetId;
				var PageSourceType = conn.endpoints[0].anchor.type;
				var PageTargetType = conn.endpoints[1].anchor.type;
				jsPlumb.detach(conn);

				$('.sureaaa').unbind("click");
				$(".sureaaa").click(function() {
					var PageSourceId = aaa;
					var PageTargetId = bbb;
					var innercont = $(".inputcont").val();
					var common = {
						anchors: [PageSourceType, PageTargetType],
						endpoints: ["Blank", "Blank"],
						label: innercont,
						cssClass: PageSourceId + PageTargetId,
						overlays: [
							["Arrow",{
								width: 20,
								length: 20,
								location: 1
							}]
						],
					};

					jsPlumb.connect({
						source: PageSourceId,
						target: PageTargetId,
					}, common);

					$("." + PageSourceId + PageTargetId).next().html(innercont)
					$(".fuchuang").css({
						"display": "none"
					});

				})

				sessionStorage['currentChartAmount'] = sessionStorage['currentChartAmount'] + 2;

			});
		</script>
	</body>

</html>