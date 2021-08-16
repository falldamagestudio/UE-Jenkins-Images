<!--
 Copyright 2020 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under the License
 is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 implied. See the License for the specific language governing permissions and limitations under the
 License.
-->

# GCE Plugin for Jenkins - with persistent VM support

This is a fork of the [Google Compute Engine Plugin for Jenkins](https://github.com/jenkinsci/google-compute-engine-plugin). It adds support for persisting VMs:

* When the plugin decides to scale down, it can choose to stop an instance instead of deleting it.
* Later on, when the plugin decides to scale up, it will prefer to re-use an instance rather than creating a new one.

Stopped instances retain state (intermediate build results, Docker layer cache, ...), allowing for incremental builds, without costing nearly as much as running instances 24/7.

These changes could potentially be folded back into the parent repository. They need to be well tested though; right now, there are edge cases where instances are forgotten about and left behind.

