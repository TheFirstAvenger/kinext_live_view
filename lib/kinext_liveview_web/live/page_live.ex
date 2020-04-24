defmodule KinextLiveviewWeb.PageLive do
  use KinextLiveviewWeb, :live_view

  require Logger

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       context: nil,
       device: nil,
       video: nil,
       device_count: 0,
       frame: nil,
       continue_video: false,
       tilt_degrees: nil,
       current_led_color: nil
     )}
  end

  def handle_event("load_context", _data, socket) do
    {:ok, context} = Kinext.Context.init()
    {:ok, count} = Kinext.Context.num_devices(context)
    :timer.sleep(100)
    {:noreply, assign(socket, context: context, device_count: count)}
  end

  def handle_event("load_device", _data, %{assigns: %{context: context}} = socket) do
    {:ok, device} = Kinext.Context.open_device(context, 1)
    {:ok, tilt_degrees} = Kinext.Device.get_tilt_degs(device)
    {:noreply, assign(socket, context: context, device: device, tilt_degrees: tilt_degrees)}
  end

  def handle_event(
        "tilt_up",
        _data,
        %{assigns: %{device: device, tilt_degrees: tilt_degrees}} = socket
      ) do
    new_tilt_degrees = trunc(min(tilt_degrees + 1, 31))
    :ok = Kinext.Device.set_tilt_degs(device, new_tilt_degrees)
    {:noreply, assign(socket, tilt_degrees: new_tilt_degrees)}
  end

  def handle_event(
        "tilt_down",
        _data,
        %{assigns: %{device: device, tilt_degrees: tilt_degrees}} = socket
      ) do
    new_tilt_degrees = trunc(max(tilt_degrees - 1, -31))
    :ok = Kinext.Device.set_tilt_degs(device, new_tilt_degrees)
    {:noreply, assign(socket, tilt_degrees: new_tilt_degrees)}
  end

  def handle_event(
        "set_led_color",
        %{"led_color" => %{"led_color" => led_color}},
        %{assigns: %{device: device}} = socket
      ) do
    :ok = Kinext.Device.set_led(device, String.to_existing_atom(led_color))
    {:noreply, assign(socket, current_led_color: led_color)}
  end

  def handle_event("load_video", _data, %{assigns: %{context: context, device: device}} = socket) do
    {:ok, video} = Kinext.Video.new(context, device)
    {:noreply, assign(socket, video: video)}
  end

  def handle_event("get_picture", _data, %{assigns: %{video: video}} = socket) do
    {:ok, frame} = Kinext.Video.get_frame(video)
    {:noreply, assign(socket, frame: frame)}
  end

  def handle_event("start_video", _data, %{assigns: %{video: video}} = socket) do
    spawn_video_pid(video)
    {:noreply, assign(socket, continue_video: true)}
  end

  def handle_event("stop_video", _data, socket) do
    {:noreply, assign(socket, continue_video: false)}
  end

  def handle_info(
        {:video_frame, frame},
        %{assigns: %{video: video, continue_video: continue_video}} = socket
      ) do
    if continue_video do
      spawn_video_pid(video)
    end

    {:noreply, assign(socket, frame: frame)}
  end

  defp spawn_video_pid(video) do
    liveview_pid = self()

    spawn(fn ->
      {:ok, frame} = Kinext.Video.get_frame(video)
      send(liveview_pid, {:video_frame, frame})
    end)
  end
end
