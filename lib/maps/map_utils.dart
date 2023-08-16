import 'package:url_launcher/url_launcher.dart';


class MapUtils
{
  MapUtils._();

  static void lauchMapFromSourceToDestination(sourceLat, sourceLng, destinationLat, destinationLng) async
  {
    String mapOptions =
    [
      'saddr=$sourceLat,$sourceLng',
      'daddr=$destinationLat,$destinationLng',
      'dir_action=navigate'
    ].join('&');

    final mapUrl = 'https://www.google.com/maps?$mapOptions';

    if(await canLaunch(mapUrl))
    {
      await launch(mapUrl);
    }
    else
    {
      throw "Could not launch $mapUrl";
    }
  }

  static void buildGoogleMapsURL( sourceLat,  sourceLng,  destinationLat,  destinationLng) async {
    final baseUrl = 'https://www.google.com/maps/dir/?api=1';
    final source = '$sourceLat,$sourceLng';
    final destination = '$destinationLat,$destinationLng';

    final url = '$baseUrl&origin=$source&destination=$destination';



    print("url $url");

    // final result = await openUrl(googleMapUrl);
    // if (result.exitCode == 0) {
    //   print('URL should be open in your browser');
    // } else {
    //   print('Something went wrong (exit code = ${result.exitCode}): '
    //       '${result.stderr}');
    // }

    if(await canLaunch(url))
    {
      await launch(url);
    }
    else
    {
      throw "Could not launch $url";
    }
  }
}

