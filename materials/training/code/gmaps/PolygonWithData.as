package code.gmaps {

	import com.google.maps.overlays.EncodedPolylineData;
	import com.google.maps.overlays.Polygon;
	import com.google.maps.overlays.PolygonOptions;

	public class PolygonWithData extends Polygon {
	
		private var stateID:String;
		private var iso2:String;
		private var ruName:String;
		private var enName:String;
	
		public function PolygonWithData(encodedData:Array, options:PolygonOptions, stateID:String, iso2:String, ruName:String, enName:String) {
			
			// Вызываем конструктор родительского класса Polygon (Polygon(points:Array, options?:PolygonOptions)), который
			// ничего не возвращает
			super([]);
			
			// Устанавливаем настройки полигонов
			setOptions(options);
			
			var len:int = encodedData.length;
			for (var i:int = 0; i < len; i++) {
				setPolylineFromEncoded(i, encodedData[i]); 
			}
			
			this.stateID = stateID;
			this.iso2    = iso2;
			this.ruName  = ruName;
			this.enName  = enName;
		
		}
		
		public function getData():Object { 
		
			return { stateID: stateID, iso2: iso2, ru: ruName, en: enName };
			
		}
	
	}

}