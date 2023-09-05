import boto3
import json
from datetime import datetime, timedelta
import requests

dynamodb_id = "${DYNAMODB_ID}"

request_url = "https://routes.googleapis.com/directions/v2:computeRoutes"

request_headers = {
	"Content-Type": "application/json",
	"X-Goog-Api-Key": "${GOOGLE_API_KEY}",
	"X-Goog-FieldMask": "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline"
}

locations = {
	"snowdon": {"lat": 53.0802711, "lng": -4.0247946},
	"scafellpike": {"lat": 54.4558115, "lng": -3.2634921},
	"bennevis": {"lat": 56.8096628, "lng": -5.0794929}
}

routes = [
	("snowdon", "scafellpike"),
	("scafellpike", "bennevis"),
	("bennevis", "scafellpike"),
	("scafellpike", "snowdon")
]

def get_current_time(type):
	now = datetime.now()+timedelta(seconds=10)
	if type == "http":
		return now.strftime("%Y-%m-%dT%H:%M:%S.000000000Z")
	elif type == "date":
		return now.strftime("%Y_%m_%d")
	elif type == "time":
		return now.strftime("%H_%M")
	else:
		return now.strftime("%Y-%m-%d %H:%M:%S")

def populate_body(origin, destination, current_time):
	request_body = {
		"origin": {
			"location": {
				"latLng": {
					"latitude": locations[origin]["lat"],
					"longitude": locations[origin]["lng"]
				}
			}
		},
		"destination":  {
			"location": {
				"latLng": {
					"latitude": locations[destination]["lat"],
					"longitude": locations[destination]["lng"]
				}
			}
		},
		"departureTime": current_time,
		"travelMode": "DRIVE",
		"routingPreference": "TRAFFIC_AWARE",
		"computeAlternativeRoutes": "false",
		"routeModifiers": {
			"avoidTolls": "false",
			"avoidHighways": "false",
			"avoidFerries": "false"
		},
		"languageCode": "en-US",
		"units": "METRIC"
	}
	return request_body

def save_to_db(dynamodb_id, origin, destination, date, time, drive_time):
	dynamodb = boto3.resource('dynamodb')
	table = dynamodb.Table(dynamodb_id)
	response = table.put_item(
		Item={
			"RouteAndTime": f"{origin}_{destination}_{date}_{time}",
			"DriveTime": drive_time
		}
	)
	return response

def handler(event, context):
	for origin, destination in routes:
		request_body = populate_body(origin, destination, get_current_time("http"))
		response = requests.post(url=request_url, headers=request_headers, data=json.dumps(request_body))
		results = json.loads(response.text)["routes"][0]["duration"][:-1]
		save_to_db(dynamodb_id, origin, destination, get_current_time("date"), get_current_time("time"), results)
		print(f"{origin}-{destination}: SUCCESSFUL")