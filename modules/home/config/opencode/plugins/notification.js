export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`afplay /System/Library/Sounds/Submarine.aiff`
      }
    },
  }
}
