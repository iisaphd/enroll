import { Controller } from "stimulus";
import StimulusReflex from 'stimulus_reflex';
import CableReady from 'cable_ready'
import consumer from '../channels/consumer';

export default class extends Controller {
  connect() {
    StimulusReflex.register(this)
    const controller = this
    consumer.subscriptions.create(
      { channel: 'SeedRowProcessingChannel' }, {
        received (data) {
          if (data.cableReady) CableReady.perform(data.operations)
        }
      }
    )
  }

  processSeed(e) {
    console.log("Hitting the processing seed thingie.");
    e.currentTarget.disabled = true;
    e.currentTarget.value = 'Processing Seed';

  }
}
