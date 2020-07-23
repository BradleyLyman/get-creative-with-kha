package;

import kha.Window;
import kha.Scheduler;
import kha.Assets;
import kha.System;

class Main {
  /**
    The application's entrypoint is always hosted in main.
  **/
  public static function main() {
    System.start({
      title: 'first app',
      width: 1366,
      height: 768,
      framebuffer: {samplesPerPixel: 4}
    }, run);
  }

  /**
    Invoked once the system is ready.
    Load all of the application assets before creating the app. This means the
    App can safely do work in it's constructor.
  **/
  private static function run(window:Window):Void {
    Assets.loadEverything(() -> {
      final app = new App();
      Scheduler.addTimeTask(app.update, 0, 1.0 / 60.0);
      System.notifyOnFrames(app.render);
    });
  }
}
