
import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 25,
  duration: '5m',
};

export default function () {
  const response = http.get(
    'http://surge-ready-alb-159524735.ap-south-1.elb.amazonaws.com/work'
  );

  check(response, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}
