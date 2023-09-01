import 'package:flutter_test/flutter_test.dart';
import 'package:solarisdemo/infrastructure/device/device_presenter.dart';
import 'package:solarisdemo/models/device.dart';
import 'package:solarisdemo/redux/device/device_state.dart';


void main() {
  final device = Device(
    deviceId: "deviceId",
    deviceName: "deviceName",
  );

  test("When fetching is in progress it should return loading", () {
    // given
    final deviceBindingLoadingState = DeviceBindingLoadingState();

    // when
    final viewModel = DeviceBindingPresenter.presentDeviceBinding(deviceBindingState: deviceBindingLoadingState);

    // then
    expect(viewModel, isA<DeviceBindingLoadingViewModel>());
  });

  test("When fetching is failed it should return error", () {
    // given
    final deviceBindingErrorState = DeviceBindingErrorState();

    // when
    final viewModel = DeviceBindingPresenter.presentDeviceBinding(deviceBindingState: deviceBindingErrorState);

    // then
    expect(viewModel, isA<DeviceBindingErrorViewModel>());
  });

  test("When fetching is successful it should return fetched", () {
    // given
    final deviceBindingFetchedState = DeviceBindingFetchedState([device], device);

    // when
    final viewModel = DeviceBindingPresenter.presentDeviceBinding(deviceBindingState: deviceBindingFetchedState);

    // then
    expect(viewModel, isA<DeviceBindingFetchedViewModel>());
    expect((viewModel as DeviceBindingFetchedViewModel).devices, [device]);
  });
}
