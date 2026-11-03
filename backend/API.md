routes:id,name,destination,path,created_at
stops:id,route_id,name,landmark,lat,lng,stop_order
buses:id,route_id,bus_number,bus_fleet,colour
bus_positions:bus_id,lat,lng,speed,updated_at

##fast api(run: uvicorn main:app-reload)
get / ->{"message":"welcome to bussaathi
}

get/stops ->{"stops":[{id,route_id,name,landark,lat,lng,stop_order},...]}
