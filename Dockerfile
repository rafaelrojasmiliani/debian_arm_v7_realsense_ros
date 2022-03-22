FROM --platform=linux/arm/v7 rafa606/debian_arm_v7_realsense
WORKDIR /catkinws
ENV SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt
SHELL ["/bin/bash", "-c"]
RUN cd /librealsense/build && make install
RUN mkdir  /catkinws/src && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o \
                        Dpkg::Options::="--force-confnew" \
                        gnupg python3 python3-dev python3-pip build-essential \
                        libyaml-cpp-dev lsb-release isc-dhcp-server libnss-mdns \
                        avahi-daemon \
                        avahi-autoipd \
                        openssh-server \
                        isc-dhcp-client \
                        vim \
                        screen \
                        tmux \
                        netcat \
                        iproute2 && \
    rm -rf /var/lib/apt/lists/* && \
    sh -c """ \
    echo deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main \
        > /etc/apt/sources.list.d/ros-latest.list \
    """ && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
        --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o \
        Dpkg::Options::="--force-confnew" \
        build-essential \
        git python-pip python-setuptools gcc libpq-dev \
        python-dev  python-pip python3-dev python3-pip python3-venv \
        python3-wheel python-rosdep python-rosinstall-generator \
        python-wstool python-rosinstall && \
    rosdep init && rosdep update && \
    rosinstall_generator \
        roscpp \
        std_msgs \
        pluginlib \
        realtime_tools \
        actionlib_msgs \
        message_generation \
        actionlib \
        geometry_msgs \
        industrial_robot_status_interface \
        sensor_msgs \
        std_srvs \
        tf \
        tf2_geometry_msgs \
        tf2_msgs \
        map_msgs \
        tf_conversions \
        freenect_stack \
        image_common \
        rgbd_launch \
        vision_opencv \
        image_pipeline \
        geometry2 \
        realsense2_camera \
        realsense2_camera_msgs \
        realsense2_description \
        cv-bridge \
        --rosdistro noetic --deps --wet-only --tar > ros.rosinstall && \
    wstool init -j8 src ros.rosinstall && \
    rosdep install -r -q  --from-paths src --ignore-src --rosdistro noetic -y && \
    rm -rf /var/lib/apt/lists/* && \
    src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -DCATKIN_SKIP_TESTING=ON --install-space /opt/ros/noetic -j2 -DPYTHON_EXECUTABLE=/usr/bin/python3 && \
    cd / && rm -rf /catkinws/*
