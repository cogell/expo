package expo.modules.kotlin.events

enum class EventName {
  MODULE_CREATE,
  MODULE_DESTROY,

  /**
   * Called when the host activity receives a resume event (e.g. Activity.onResume)
   */
  ACTIVITY_ENTERS_FOREGROUND,

  /**
   * Called when host activity receives pause event (e.g. Activity.onPause)
   */
  ACTIVITY_ENTERS_BACKGROUND,

  /**
   * Called when host activity receives destroy event (e.g. Activity.onDestroy)
   */
  ACTIVITY_DESTROYS
}
