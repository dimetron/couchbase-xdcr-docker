import http from "k6/http";
import { check, sleep } from "k6";

export default function() {
    let resA = http.get(`http://192.168.1.100:8080/health`, {tags: {name: 'HealthCheck'}});
	let resB = http.get(`http://192.168.1.100:8080/health`, {tags: {name: 'HealthCheck'}});
	check(resA, {
        "Cluster A status 200": (r) => r.status === 200
    });	
	check(resB, {
        "Cluster B status 200": (r) => r.status === 200
    });
	sleep(1);
};