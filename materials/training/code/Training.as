package code {

	import fl.controls.List;
	import fl.data.DataProvider;
	import fl.motion.Color;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.ui.Mouse; 
	import flash.ui.MouseCursor;
	
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapOptions;
	import com.google.maps.MapType;
	import com.google.maps.PaneId;
	import com.google.maps.controls.MapTypeControl;
	import com.google.maps.controls.PositionControl;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.overlays.EncodedPolylineData;

	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;
	import com.google.maps.overlays.Polyline;
	import com.google.maps.overlays.PolylineOptions;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.ClientGeocoderOptions;
	import com.google.maps.services.GeocodingEvent;

	import code.gmaps.PolygonWithData;
	import code.net.ServerMethods;

	public class Training extends Sprite {
	
		private static const KEY:String 	 			= "ABQIAAAApfP-ydF6DK2aVjYmIR5uzxRDBeF5130FYlWbIyn_RmCszB2SVxR2kxhTD_MO2qE6qqoMoA-1FWGoug";
		private static const LANGUAGE:String 			= "ru";
		private static const MAP_WIDTH:int   	        = 575;
		private static const MAP_HEIGHT:int  			= 680;
		
		private static const BOUNDARY_COLOR:uint		= 0x544001;
		private static const COLOR_FROM:uint    		= 0xFEE18B;
		private static const COLOR_TO:uint    		    = 0xB08502;
		private static const SELECTED_STATE_COLOR:uint  = 0xF05C37;
		
		// Координаты центров континентов
		// Весь мир, Европа, Азия, Северная Америка, Южная Америка, Африка, Австралия и Океания
		private static const CENTER_COORDS:Array        = [ [55, 28, 3], [67.8, 21, 3], [60, 105, 2.2], [65, -91, 2.3], [-27, -63, 3.5], [5, 14.5, 3], [-26.5, 146, 3] ];
		
		// Список стран list
		private static const LIST_X:int      			= 580;
		private static const LIST_HEIGHT:int 			= 680;
		private static const LIST_WIDTH:int  			= 220;
		private var list:List;
		
		// Карта
		private var map:Map;
		
		// Загруженные контуры стран
		private var polygons:Array = [];
		
		// Контур выбранного государства (клик по контуру)
		private var currentContour:Object;
		
		// Выбранный континент
		private var numberPartOfWorld:int;

		// API
		private var serverMethods:ServerMethods;

		public function Training() {
			
			setPartOfWorld(3);
			
		}
		
		public function setPartOfWorld(number:int):void {
		
			numberPartOfWorld = number;
		
			// Настройка списка отображения
			list = new List();
			list.move(LIST_X, 0);
			list.height = LIST_HEIGHT;
			list.width  = LIST_WIDTH;
			list.addEventListener(Event.CHANGE, onItemClick);
			addChild( list );
				
			// Загрузка названий государств
			if (!numberPartOfWorld) {
				serverMethods = new ServerMethods("", "", "getNames");
				serverMethods.addEventListener(ServerMethods.LOAD, onGetNames);
			}

			// Инициализация карты
			initMap();
			
		}
		
		private function addContours():void {
		
			for each (var p:PolygonWithData in polygons) map.addOverlay(p);
			//polygons = null;
		
		}
		
		private function initMap():void {
		
			map          = new Map();
			map.key      = KEY;
			map.language = LANGUAGE;
			map.sensor   = "false";
			map.setSize(new Point(MAP_WIDTH, MAP_HEIGHT));			
			map.addEventListener(MapMouseEvent.CLICK, onMapClick);
			map.addEventListener(MapEvent.MAP_READY, onMapReady);
			addChild(map);
				
		}
		
		private function onGetContour(e:Event):void {
		
			var incomingData:XML  = e.target.getData();
			var encodedData:Array = [];
			var options:PolygonOptions = new PolygonOptions({
															
				strokeStyle: {
					thickness: 1,
					color: BOUNDARY_COLOR,
					alpha: 0.8,
					pixelHinting: true
				},
				fillStyle: {
					color: SELECTED_STATE_COLOR,
					alpha: 0.8
				},
				tooltip: "<p align='center'>" + incomingData.@ru + "\n(" + incomingData.@en + ")</p>"
				
			}); 
			
			for each (var p:XML in incomingData.polygon) {
				
				encodedData.push( new EncodedPolylineData( String( p.points ), 
													   	   int( p.zoomFactor ), 
													   	   String( p.levels ),
													   	   int( p.numLevels )) 
				);
			
			}				

			var polygon:PolygonWithData = new PolygonWithData(encodedData, options, incomingData.@id, incomingData.@iso2, incomingData.@ru, incomingData.@en);
			polygon.addEventListener(MapMouseEvent.CLICK, onPolygonClick);
			polygon.addEventListener(MapMouseEvent.ROLL_OUT, onPolygonOut);
			polygon.addEventListener(MapMouseEvent.ROLL_OVER, onPolygonOver);
					
			// Отображаем контур
			map.clearOverlays();
			map.addOverlay(polygon);
			
			var latLng:LatLng = new LatLng(incomingData.@lat, incomingData.@lng);
			map.panTo(latLng);
		
		}
		
		private function onGetNames(e:Event):void {
		
			var incomingData:XML  = e.target.getData();
			var names:Array       = [];
			
			for each (var s:XML in incomingData.s) names.push({ label: s.@ru, data: s.@id });								
			list.dataProvider = new DataProvider(names);
						
		}
		
		private function onGetStates(e:Event):void {
		
			var incomingData:XML  = e.target.getData();
			var names:Array       = [];
			var encodedData:Array;
			var polygon:PolygonWithData;
			var options:PolygonOptions; 
			
			var countStates:int = incomingData.children().length();
			var i:int           = 0;
			var color:uint;
			
			for each (var s:XML in incomingData.s) {
				
				names.push({ label: s.ru, data: s.id });
				encodedData = [];

				for each (var p:XML in s.polygons.polygon) {
				
					encodedData.push( new EncodedPolylineData( String( p.points ), 
														   	   int( p.zoomFactor ), 
														   	   String( p.levels ),
														   	   int( p.numLevels )) 
					);
			
				}

				color = Color.interpolateColor(COLOR_FROM, COLOR_TO, i/countStates);
				i++;
				
				options = new PolygonOptions({
															
					strokeStyle: {
						thickness: 1,
						color: BOUNDARY_COLOR,
						alpha: 0.8,
						pixelHinting: true
					},
					fillStyle: {
						color: color,
						alpha: 0.8
					},
					tooltip: "<p align='center'>" + s.ru + "\n(" + s.en + ")</p>"
				
				});

				var polygon:PolygonWithData = new PolygonWithData(encodedData, options, s.id, s.iso2, s.ru, s.en);
				polygon.addEventListener(MapMouseEvent.CLICK, onPolygonClick);
				polygon.addEventListener(MapMouseEvent.ROLL_OUT, onPolygonOut);
				polygon.addEventListener(MapMouseEvent.ROLL_OVER, onPolygonOver);
				polygons.push(polygon);
				
			}
					
			list.dataProvider = new DataProvider(names);
			
			// Отображаем контуры загруженных государств
			addContours();
			
		}
		
		private function onItemClick(e:Event):void {
			
			if (!numberPartOfWorld) {
				
				// Загрузка названий государств
				serverMethods = new ServerMethods("", "", "getContour", { sid: list.selectedItem.data });
				serverMethods.addEventListener(ServerMethods.LOAD, onGetContour);
				
			}
			else {
			
				var polygonCur:PolygonWithData = polygons[list.selectedIndex];
				var stateData:Object 		   = polygonCur.getData();
			
				if (!currentContour || currentContour.polygon != polygonCur) {
				
					// Меняем настройки предыдущего выбранного полигона
					if (currentContour) {
						var polygonPrev:PolygonWithData = currentContour.polygon;
						polygonPrev.setOptions(currentContour.options);
					}
				
					// Сохраняем настройки выбранного полигона
					currentContour = { polygon: polygonCur, options: polygonCur.getOptions() };
					
					// И устанавливаем новые
					var options:PolygonOptions = new PolygonOptions({
																	
						strokeStyle: {
							thickness: 1,
							color: BOUNDARY_COLOR,
							alpha: 0.8,
							pixelHinting: true
						},
						fillStyle: {
							color: SELECTED_STATE_COLOR,
							alpha: 0.8
						},
						tooltip: "<p align='center'>" + stateData.ru + "\n(" + stateData.en + ")</p>"
						
					});
				
					polygonCur.setOptions(options);
				
				}
				
				var latLngBounds:LatLngBounds = polygonCur.getLatLngBounds();
				showInfoWindow(latLngBounds.getCenter(), stateData.iso2, stateData.ru, stateData.en);
				
			}
		
		}
		
		private function onMapClick(e:MapMouseEvent):void {
		
			//trace(e.latLng);
		
		}
		
		private function onMapReady(e:Event):void {
	
			var center:Array = CENTER_COORDS[numberPartOfWorld];
			map.setCenter(new LatLng(center[0], center[1]), center[2], MapType.SATELLITE_MAP_TYPE);
			
			map.addControl(new ZoomControl());
			map.addControl(new PositionControl());
			
			// Загрузка контуров и названий государств
			if (numberPartOfWorld) {
				serverMethods = new ServerMethods("", "", "getStates", { part: numberPartOfWorld });
				serverMethods.addEventListener(ServerMethods.LOAD, onGetStates);
			}
			
			setChildIndex(list, numChildren - 1);
		
		}
		
		private function onPolygonClick(e:MapMouseEvent):void {
			
			var polygonCur:PolygonWithData = e.feature as PolygonWithData;
			var stateData:Object 		   = polygonCur.getData();
			
			if (numberPartOfWorld && (!currentContour || currentContour.polygon != polygonCur)) {
				
				// Меняем настройки предыдущего выбранного полигона
				if (currentContour) {
					var polygonPrev:PolygonWithData = currentContour.polygon;
					polygonPrev.setOptions(currentContour.options);
				}
				
				// Сохраняем настройки выбранного полигона
				currentContour = { polygon: polygonCur, options: polygonCur.getOptions() };
				
				// И устанавливаем новые
				var options:PolygonOptions = new PolygonOptions({
																
					strokeStyle: {
						thickness: 1,
						color: BOUNDARY_COLOR,
						alpha: 0.8,
						pixelHinting: true
					},
					fillStyle: {
						color: SELECTED_STATE_COLOR,
						alpha: 0.8
					},
					tooltip: "<p align='center'>" + stateData.ru + "\n(" + stateData.en + ")</p>"
					
				});
				
				polygonCur.setOptions(options);
				
			}
			
			showInfoWindow(e.latLng, stateData.iso2, stateData.ru, stateData.en);
			
		}

		private function onPolygonOut(e:MapMouseEvent):void { Mouse.cursor = MouseCursor.AUTO; }
		private function onPolygonOver(e:MapMouseEvent):void { Mouse.cursor = MouseCursor.BUTTON; }
	
		private function showInfoWindow(centerCoords:LatLng, iso2:String, ruName:String, enName:String):void {
		
			// Отображаем информационное окно в точке, по которой кликнули
			var titleFormat:TextFormat = new TextFormat();
			titleFormat.bold           = true;
			
			var imageURL:String = "http://flagpedia.net/data/flags/small/" + iso2 + ".png";
			var windowOptions:InfoWindowOptions = new InfoWindowOptions({ width: 300, height: 154, titleFormat: titleFormat, title: ruName + "\n" + enName, contentHTML: "<img src='" + imageURL + "'/>" });
			map.openInfoWindow(centerCoords, windowOptions);
		
		}
	
	}

}