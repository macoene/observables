defmodule Observables.Obs do
    

    alias Observable.{Random, Printer, Map, Filter, ProducerConsumer}

# GENERATORS ###################################################################
 
    def from_pid(pid) do
        fn(observer) ->
            GenObservable.subscribe(pid, observer)
        end
    end

# CONSUMER AND PRODUCER ########################################################

    def map(observable_fn, f) do
        # Create the mapper function.
        mapper = fn(v) ->
            new_v = f.(v)
            {:value, new_v}
        end
        create_action(observable_fn, mapper)
    end

    def each(observable_fn, f) do
        # Create the mapper function.
        eacher = fn(v) ->
            f.(v)
            {:value, v}
        end
        create_action(observable_fn, eacher)
    end

    def filter(observable_fn, f) do
        # Creat the wrapper for the filter function.
        filterer = fn(v) ->
            if f.(v) do
                {:value, v}
            else
                {:novalue}
            end
        end
        create_action(observable_fn, filterer)
    end

# TERMINATORS ##################################################################

    def print(observable_fn) do
        action = fn(v) -> IO.puts(v) ; {:next_value, v} end
        create_consumer(observable_fn, action)
    end

# HELPERS ######################################################################


    defp create_action(observable_fn, action) do
        # Start the producer/consumer server.
        {:ok, pid} = GenObservable.start_link(Action, action)

        # Creat the continuation.
        fn(observer) ->
            observable_fn.(pid)
            GenObservable.subscribe(pid, observer)
        end
    end

    defp create_consumer(observable_fn, action) do
        {:ok, pid} = GenObservable.start_link(Action, action)
        observable_fn.(pid)
        :ok
    end
end