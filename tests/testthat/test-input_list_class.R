context("InputList class")

describe("InputList", {
  it ("correctly updates values when an input value changes", {
    inputs <- list(x = mwSlider(0, 10, 5), y = mwSlider(x, 10, 0))
    inputs <- initAllInputs(inputs, initEnv(parent.frame(), 1))
    inputList <- InputList(inputs)$init()

    expect_equal(inputList$getInputById("output_1_y")$value, 5)

    inputList$setValue(inputId = "output_1_x", value = 7)
    expect_equal(inputList$getInputById("output_1_x")$value, 7)
  })

  it("detects dependencies between inputs", {
    inputs <- list(
      x = mwSlider(0, 10, 5),
      y = mwSlider(x, 10, 0, .display = z > 3),
      z = mwSlider(0, x, 0)
    )
    inputs <- initAllInputs(inputs, initEnv(parent.frame(), 1))
    inputList <- InputList(inputs)$init()
    expect_equal(inputList$getDeps(inputList$getInputById("output_1_x")),
                 list(params = character(), display = character()))
    expect_length(inputList$getInputById("output_1_y")$revDeps, 0)
    expect_equal(inputList$getDeps(inputList$getInputById("output_1_y")),
                 list(params = "output_1_x", display = "output_1_z"))
    expect_equal(inputList$getInputById("output_1_x")$revDeps, c("output_1_y", "output_1_z"))
    expect_equal(inputList$getInputById("output_1_z")$displayRevDeps, c("output_1_y"))
  })

  inputs <- list(x = mwSlider(0, 10, 5), y = mwSlider(0, 10, 0))
  inputs2 <- list(x = mwSlider(0, 10, 6), y = mwSlider(0, 10, 1))
  inputs <- c(
    initAllInputs(list(shared = mwText("test")), initEnv(parent.frame(), 0)),
    initAllInputs(inputs, initEnv(parent.frame(), 1)),
    initAllInputs(inputs2, initEnv(parent.frame(), 2))
  )
  inputList <- InputList(inputs)$init()

  it ("gets and updates an input by name and chartId", {
    # Get Input
    # Individual inputs
    expect_equal(inputList$getInput("x", 1)$value, 5)
    expect_equal(inputList$getInput("x", 2)$value, 6)
    # Shared inputs
    expect_equal(inputList$getInput("shared", 1)$value, "test")
    expect_equal(inputList$getInput("shared", 2)$value, "test")

    # Get input value
    # Individual inputs
    expect_equal(inputList$getValue("x", 1), 5)
    expect_equal(inputList$getValue("x", 2), 6)
    # Shared inputs
    expect_equal(inputList$getValue("shared", 1), "test")
    expect_equal(inputList$getValue("shared", 2), "test")

    # Update input value
    # Individual inputs
    expect_equal(inputList$setValue("x", 4, 1), 4)
    expect_equal(inputList$setValue("x", 5, 2), 5)
    expect_equal(inputList$getValue("x", 1), 4)
    expect_equal(inputList$getValue("x", 2), 5)
    # Shared inputs
    expect_equal(inputList$setValue("shared", "test1", 1), "test1")
    expect_equal(inputList$getValue("shared", 1), "test1")
    expect_equal(inputList$setValue("shared", "test2", 1), "test2")
    expect_equal(inputList$getValue("shared", 2), "test2")

    it ("gets all values for one chart", {
      for (i in 1:2) {
        values <- inputList$getValues(i)
        expect_is(values, "list")
        expect_named(values, c("shared", "x", "y"), ignore.order = TRUE)
        for (n in c("shared", "x", "y")) {
          expect_equal(values[[n]], inputList$getValue(n, i))
        }
      }
    })

    it ("indicates if an input is shared or not", {
      expect_true(inputList$isShared("shared"))
      expect_true(! inputList$isShared("x"))
      expect_true(! inputList$isShared("y"))
    })

    it ("does not modify values until it is initialized", {
      inputs <- list(x = mwSlider(0, 10, 5), y = mwSlider(x, 10, 0))
      inputs <- initAllInputs(inputs, initEnv(parent.frame(), 1))
      inputList <- InputList(inputs)

      expect_equal(inputList$getInputById("output_1_y")$value, 0)
      inputList$setValue(inputId = "output_1_x", value = 7)
      expect_equal(inputList$getInputById("output_1_y")$value, 0)

      inputList$init()
      expect_equal(inputList$getInputById("output_1_y")$value, 7)
      inputList$setValue(inputId = "output_1_x", value = 8)
      expect_equal(inputList$getInputById("output_1_y")$value, 8)
    })

    it ("can add an input", {
      e <- initEnv(parent.frame(), 1)
      inputs <- list(x = mwSlider(0, 10, 5), y = mwSlider(x, 10, 0))
      inputs <- initAllInputs(inputs, e)
      inputList <- InputList(inputs[1])$init()
      inputList$addInputs(inputs[2])
      expect_equal(inputList$getInputById("output_1_y")$value, 5)

      inputList$setValue(inputId = "output_1_x", value = 7)
      expect_equal(inputList$getInputById("output_1_y")$value, 7)

      values <- inputList$getValues(1)
      expect_is(values, "list")
      expect_named(values, c("x", "y"), ignore.order = TRUE)
      for (n in c("x", "y")) {
        expect_equal(values[[n]], inputList$getValue(n, 1))
      }
    })

    it ("can add a group of inputs", {
      e <- initEnv(parent.frame(), 1)
      inputs <- list(x = mwSlider(0, 10, 5), grp = mwGroup(y = mwSlider(x, 10, 0)))
      initInputEnv(inputs, e)
      inputList <- InputList(inputs[1])$init()
      inputList$addInputs(inputs[2])

      expect_equal(nrow(inputList$inputTable), 3)
      expect_equal(sort(inputList$inputTable$name), c("grp", "x", "y"))
    })

    it ("can remove an input", {
      e <- initEnv(parent.frame(), 1)
      inputs <- list(x = mwSlider(0, 10, 5), y = mwSlider(x, 10, 0))
      inputs <- initAllInputs(inputs, e)
      inputList <- InputList(inputs)$init()
      inputList$removeInput("y", 1)
      expect_null(inputList$getInputById("output_1_y"))
      expect_length(inputList$getInputById("output_1_x")$revDeps, 0)
      expect_silent(inputList$setValue(inputId = "output_1_x", value = 7))

      values <- inputList$getValues(1)
      expect_equal(values, list(x = 7))
    })

    it ("can remove a group of inputs", {
      e <- initEnv(parent.frame(), 1)
      inputs <- list(x = mwSlider(0, 10, 5), grp = mwGroup(y = mwSlider(x, 10, 0)))
      inputs <- initAllInputs(inputs, e)
      inputList <- InputList(inputs)$init()
      inputList$removeInput("grp", 1)
      expect_null(inputList$getInputById("output_1_y"))
      expect_null(inputList$getInputById("output_1_grp"))
      expect_length(inputList$getInputById("output_1_x")$revDeps, 0)
      expect_silent(inputList$setValue(inputId = "output_1_x", value = 7))

      values <- inputList$getValues(1)
      expect_equal(values, list(x = 7))
    })
  })
})
