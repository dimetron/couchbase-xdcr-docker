import http from "k6/http";
import { check, sleep } from "k6";

let count = 1

export default function() {
  count++;
  
  var payload = JSON.stringify({ key: `key-${count}`, value: `value-${count}`});
  var params =  { headers: { "Content-Type": "application/json" } };
 
  var url1 = "http://192.168.1.100:8080/api/storage/write-key";
  var url2 = "http://192.168.1.100:8080/api/storage/read-key";
  
  let res1 = http.post(url1, payload, params);
  check(res1, {
        "WRITE status 200": (r) => r.status === 200
  });

  sleep(1);
  
  let res2 = http.post(url2, payload, params);
  check(res2, {
        "READ status 200": (r) => r.status === 200
  });
};