<?php

    // Переход к 5 знакам после запятой вместо 6

    require "connect.php";

    $stateID = intval($_GET['stateID']);

    $query   = "SELECT contours_t FROM borders WHERE state_id = $stateID";
    $result  = mysql_query($query);
    $contour = mysql_result($result, 0);

    $polygons = explode(')),((', $contour);

    // Убираем "MULTIPOLYGON((("
    $polygons[0] = substr($polygons[0], 15);

    // Убираем три последние круглые скобки ")))"
    $count            = count($polygons) - 1;
    $polygons[$count] = substr($polygons[$count], 0, -3);

    $newPolygons      = array();

    // $polygons - ['lat1 lng1,lat2 lng2,...', 'lat1 lng1,lat2 lng2,...', ...]
    foreach ($polygons as $points) {

        // $points - 'lat1 lng1,lat2 lng2,...'
        // $ps - ['lat1 lng1', 'lat2 lng2', ...]
        $ps        = explode(',', $points);
        $pointsStr = '';

        foreach ($ps as $p) {

            // $p - 'lat1 lng1'
            // $latLng - ['lat1', 'lng1']
            $latLng = explode(' ', $p);
            $lat    = intval($latLng[0] * 1e5) / 1e5;
            $lng    = intval($latLng[1] * 1e5) / 1e5;

            if (!$pointsStr) {
                $pointsStr .= "$lat $lng";
            }
            else {
                $pointsStr .= ",$lat $lng";
            }

        }

        array_push($newPolygons, $pointsStr);

    }

    $newContour  = 'MULTIPOLYGON(((';
    $newContour .= implode(')),((', $newPolygons);
    $newContour .= ')))';

    $query = "UPDATE borders SET contours_ts = '$newContour' WHERE state_id = $stateID";
    mysql_query($query);

?>
