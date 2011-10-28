<?php

    require "connect.php";

    $method = mysql_real_escape_string($_POST['method']);

    if ($method == 'getStates') {

        // Получение контуров и названий стран
        $partOfWorld = mysql_real_escape_string($_POST['part']);

        /*$query  = "SELECT s.id,
                          s.iso2,
                          s.ru,
                          s.en,
                          AsText(b.contours) c
                   FROM states s
                   INNER JOIN borders b ON (s.id = b.state_id)
                   WHERE EXISTS (SELECT 1 FROM states_continents WHERE state_id = s.id AND continent_id = $partOfWorld)
                   ORDER BY s.id";*/

        $query  = "SELECT s.id,
                          s.iso2,
                          s.ru,
                          s.en,
                          b.contours_ts c
                   FROM states s
                   INNER JOIN borders b ON (s.id = b.state_id)
                   WHERE EXISTS (SELECT 1 FROM states_continents WHERE state_id = s.id AND continent_id = $partOfWorld)
                   ORDER BY s.id";

        $result = mysql_query($query);

        $xml    = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        $xml   .= "<states>\n";

        while ($row = mysql_fetch_assoc($result)) {

            $xml .= "<s>\n";
            $xml .= "<id>".$row['id']."</id>\n";
            $xml .= "<iso2>".$row['iso2']."</iso2>\n";
            $xml .= "<ru>".htmlspecialchars($row['ru'], ENT_QUOTES)."</ru>\n";
            $xml .= "<en>".htmlspecialchars($row['en'], ENT_QUOTES)."</en>\n";

            $polygons         = explode(')),((', $row['c']);

            // Убираем "MULTIPOLYGON((("
            $polygons[0]      = substr($polygons[0], 15);

            // Убираем три последние круглые скобки ")))"
            $count            = count($polygons) - 1;
            $polygons[$count] = substr($polygons[$count], 0, -3);

            $l1 = strlen($row['c']);
            $l2 = 0;
            $pointsCount = 0;

            $xml .= "<polygons>\n";

            foreach ($polygons as $points) {

                $encoded = encode($points);
                //$l2 += strlen($encoded[0]) + strlen($encoded[1]);
                $l2 += strlen($encoded[0]);

                $xml .= "<polygon>\n";
                $xml .= "<points>$encoded[0]</points>\n";
                $xml .= "<zoomFactor>16</zoomFactor>\n";
                $xml .= "<levels>$encoded[1]</levels>\n";
                $xml .= "<numLevels>4</numLevels>\n";
                $xml .= "</polygon>\n";

                $pointsCount += $encoded[2];

            }

            $xml .= "</polygons>\n";
            $xml .= "<l>$l1 | $l2 | $pointsCount</l>\n";
            $xml .= "</s>\n";

        }

        $xml   .= "</states>\n";

        echo $xml;

    }
    else if ($method == 'getNames') {

        $query  = "SELECT id, ru FROM states ORDER BY id";
        $result = mysql_query($query);

        $xml    = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        $xml   .= "<states>\n";

        while ($row = mysql_fetch_assoc($result)) {
                $xml .= "<s id='".$row['id']."' ru='".htmlspecialchars($row['ru'], ENT_QUOTES)."'/>\n";
        }

        $xml   .= "</states>\n";

        echo $xml;

    }
    else if ($method == 'getContour') {

        $stateID = intval($_POST['sid']);

        $query   = "SELECT s.id, s.iso2, s.ru, s.en, s.lat, s.lng, AsText(b.contours) FROM states s
                          INNER JOIN borders b ON (s.id = b.stateID)
                                WHERE s.id = $stateID";
        $query   = "SELECT s.id, s.iso2, s.ru, s.en, s.lat, s.lng, AsText(b.contours) FROM states s
                          INNER JOIN borders b ON (s.id = b.stateID)
                                WHERE s.id = $stateID";
        $result  = mysql_query($query);

        $stateID	  = mysql_result($result, 0, 0);
        $iso2		  = mysql_result($result, 0, 1);
        $ruName   	  = mysql_result($result, 0, 2);
        $enName           = mysql_result($result, 0, 3);
        $lat		  = mysql_result($result, 0, 4);
        $lng		  = mysql_result($result, 0, 5);

        $polygonsString   = mysql_result($result, 0, 6);
        $polygons    	  = explode(')),((', $polygonsString);
        $polygons[0] 	  = substr($polygons[0], 15);

        $count            = count($polygons) - 1;
        $polygons[$count] = substr($polygons[$count], 0, -3);

        $xml    = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        $xml   .= "<state id='$stateID' iso2='$iso2' ru='$ruName' en='$enName' lat='$lat' lng='$lng'>\n";

        foreach ($polygons as $points) {

                $encoded = encode($points);

                $xml .= "<polygon>\n";
                $xml .= "<points>$encoded[0]</points>\n";
                $xml .= "<zoomFactor>2</zoomFactor>\n";
                $xml .= "<levels>$encoded[1]</levels>\n";
                $xml .= "<numLevels>2</numLevels>\n";
                $xml .= "</polygon>\n";

        }

        $xml .= "</state>\n";

        echo $xml;

    }

    // Различные функции
    function encode($points) {

        $dlat = $plng = $plat = $dlng = 0;//$i = 0;

        $points = explode(',', $points);

        foreach ($points as $mapPoints) {

            $mp        = explode(' ', $mapPoints);
            $mapPoints = array('lat' => $mp[1], 'lng' => $mp[0]);

            // Если общее кол-во точек <= 16, используем все точки, иначе только каждую пятую
            //if ( (!fmod($i, 5) && count($points) > 16) || count($points) <= 16 ) {

            // С целью уменьшения занимаемого места все координаты нужно преобразовать к точности в 5 знаков после запятой,
            // а здесь убрать intval
            $late5   = intval($mapPoints['lat'] * 1e5);
            $lnge5   = intval($mapPoints['lng'] * 1e5);
            $dlat    = $late5 - $plat;
            $dlng    = $lnge5 - $plng;
            $plat    = $late5;
            $plng    = $lnge5;
            $res[0] .= encode_signed_number($dlat);
            $res[0] .= encode_signed_number($dlng);
            $res[1] .= encode_number(3);

            //}

            //$i++;

        }

        $res[2] = count($points);

        return $res;

    }

    function encode_signed_number($num) {

        $sig_num = $num << 1;
        if ($sig_num < 0) $sig_num = ~$sig_num;
        $res = encode_number($sig_num);
        return $res;

    }

    function encode_number($num) {

        $res = '';
        while ($num  >= 0x20) {
            $res .= chr((0x20 | ($num & 0x1f)) + 63);
            // Сдвиг вправо на 5 бит ($num = $num >> 5)
            $num >>=5;
        }
        $res .= chr($num + 63);

        return $res;

    }

?>