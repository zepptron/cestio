---
title: "Blogging like a Pr0!"
date: 2017-11-24T16:38:52+01:00
weight: 2
---

So you have your application running in the UCP Kubernetes Cluster. Nice. Here we'll show you how to measure your application with metrics. The following topics will be covered:

- generate metrics
- expose/push metrics
- what does it look like?
- collect metrics
- visualize metrics
- installing prometheus locally
- follow up

<h3>Generate metrics</h3>
If you want to generate metrics it belongs to you and your favorite programming language how to do this. At the end there must be a label and a value that will be collected by Prometheus.

A good metric is a metric that gives you insights regarding traffic, runtime, user interaction or anything else that could be of interest for you. There are 4 types of metrics you can use: Counter, Gauge, Summary and Histogram. Those 4 types are documented [here](https://prometheus.io/docs/concepts/metric_types/). For most usecases you'll use Gauge or Counter. Just remember the following: where a counter is going up, a gauge can also decrease or be set to a value of your choice.

<h3>Expose/push metrics</h3>
There are 2 ways of exposing metrics right now. You can expose them on a http endpoint or you can push them to a so called pushgateway.

**HTTP:**

This is the easiest way and should always be preferred. Exposing metrics via http means that your service is pushing metrics to an endpoint. This also means that it has to be available the whole time. Prometheus will scrape your metrics in short intervals (expect it to happen every minute) at that point. If your webserver is down your data will be empty for that timespan. Since there is an autodiscovery implemented for Kubernetes Services in Prometheus you don't have to think about restarts/evacuation of your Pod. As long as your service is reachable your metrics will be scraped.

For most cases there are client libraries available:

- [Go](https://github.com/prometheus/client_golang)
- [Python](https://github.com/prometheus/client_python)
- [Ruby](https://github.com/prometheus/client_ruby)
- [Java](https://github.com/prometheus/client_java)
- [more..](https://prometheus.io/docs/instrumenting/clientlibs/)

You can of course use your own metrics exposer. Just make sure that you can interact with Prometheus.

**The Pushgateway:**

If your application is only up for a short period of time you'll need the pushgateway because Prometheus isn't able to create a timeseries with data that isn't accessable for the whole time. You would have empty entrys and that doesn't make sense when your app is running as expected.
When choosing to push your metrics to the pushgateway, the pushgateway will expose your metrics to prometheus. It's like a cache for your metrics when your service doesn't run long enough to be scraped by prometheus directly.
More about the pushgateway [here](https://github.com/prometheus/pushgateway)

The UCP Pushgateway resides here: [pushgateway](https://prometheus-pushgateway.ucp.fhm.de/)

The metrics endpoint here:
[pushgateway/metrics](https://prometheus-pushgateway.ucp.fhm.de/metrics)



<h3>what does it look like?</h3>

If you have never seen metrics or don't know what they need to look, take a look at this:



```
# HELP etcd_backup_count_elements ETCD elem. in object storage
# TYPE etcd_backup_count_elements gauge
etcd_backup_count_elements{instance="",job="etcd_backup_cronjob"} 47
# HELP etcd_backup_db_file_available check if db file is available
# TYPE etcd_backup_db_file_available gauge
etcd_backup_db_file_available{instance="",job="etcd_backup_cronjob"} 1
# HELP etcd_backup_db_file_size ETCD snapshot file size
# TYPE etcd_backup_db_file_size gauge
etcd_backup_db_file_size{instance="",job="etcd_backup_cronjob"} 44.820343017578125
# HELP etcd_backup_del_files_last_run ETCD deleted backupfiles on last run
# TYPE etcd_backup_del_files_last_run gauge
etcd_backup_del_files_last_run{instance="",job="etcd_backup_cronjob"} 0
# HELP etcd_backup_runtime ETCD backupscript runtime
# TYPE etcd_backup_runtime gauge
etcd_backup_runtime{instance="",job="etcd_backup_con job"} 4.036073923110962
# HELP go_gc_duration_seconds A summary of the GC  invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0.000162916
go_gc_duration_seconds{quantile="0.25"} 0.000197802
go_gc_duration_seconds{quantile="0.5"} 0.000251311
go_gc_duration_seconds{quantile="0.75"} 0.000309429
go_gc_duration_seconds{quantile="1"} 0.002650137
go_gc_duration_seconds_sum 0.062263249
go_gc_duration_seconds_count 223
```

It is always the same schema: `metric{labelA=text} $value`
This is what you need to deliver at your HTTP service or what you need to send to the pushgateway.


<h3>Collect metrics</h3>

Here is a short example script for Python in combination with docker. Run the Pushgateway like this:

 `docker run -d -p 9091:9091 prom/pushgateway`

install the pip package for prometheus:

 `pip install prometheus_client`

```
#!/usr/bin/python
import time, timeit
from prometheus_client import Gauge, CollectorRegistry, push_to_gateway

start = timeit.default_timer()  # start measuring runtime
prom_gateway = "http://localhost:9091"
registry = CollectorRegistry()
scr_run = Gauge("label_for_runtime", "script runtime", registry=registry)

time.sleep(5)

stop = timeit.default_timer()
end = stop - start  # end runtime measurement
scr_run.set(end)

push_to_gateway(prom_gateway, job="your_job_label", registry=registry)
```

And this is what you'll see at the pushgateway metrics endpoint:
```
# HELP label_for_runtime script runtime
# TYPE label_for_runtime gauge
label_for_runtime{instance="",job="your_job_label"} 4.999950885772705
```

<h3>Visualize metrics</h3>
To visualize metrics you can use Prometheus or Grafana. Here we will take a look at Prometheus. Since we have an autodiscovery of new services inside the cluster you just need to make sure to attach the following annotations to your service:

```
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
```

Deploy your application, check your metrics manually if they perform as expected and then check out Prometheus. Right now the overall instance is available here:
https://metrics.ucp.fhm.de

At the top you can enter some [PromQL](https://prometheus.io/docs/querying/basics/) commands to filter your metrics by labels or do some operations like `sum()` or `changes()` to get more insights.
At first you need to choose your metric from the dropdown below, press execute and check out the given graph. 
It should look like this:

![image](https://www.robustperception.io/wp-content/uploads/2017/04/Screen-Shot-2017-04-06-at-11.52.04.png)

Working in Prometheus is pretty easy. The logical part needs to happen before and afterwards. All in All Prometheus can give you lots of insights if you choose/use your metrics wisely.

<h3>Installing Prometheus locally</h3>
If you want to test it on your own you can simply follow this guide:
https://prometheus.io/docs/introduction/install/

Prometheus can also support you while developing new features or testing software. Every time you want to measure software prometheus can help you out. 

<h3>Follow up</h3>

Prometheus can also trigger some alerts if you think that certain values should never happen. A set of rules will trigger your logic and send everything necessary to the Prometheus Alertmanager or a tool of your choice. This topic will be covered in a different blogentry because there is a lot of stuff to know.
