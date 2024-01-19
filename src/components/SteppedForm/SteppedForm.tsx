import { useEffect } from "react";
import { Box, Button, Text } from "@chakra-ui/react";
import { createContext, useReducer } from "react";
import {
  FormAction,
  FormContextType,
  FormState,
  SteppedForm as SteppedFormType,
} from "./types";
import { updateFormDataForStep } from "./utils";
import {
  useNavigate,
  useLocation,
  createSearchParams,
  useSearchParams,
} from "react-router-dom";
import ExitModal from "../ExitModal";

const initialState: FormState = {
  currentStep: 0,
  currentForm: null,
  forms: [],
};

const reducer = (state: FormState, action: FormAction) => {
  switch (action.type) {
    case "NEXT_STEP":
      return {
        ...state,
        currentStep: state.currentStep + 1,
      };
    case "UPDATE_FORM": {
      const { payload } = action;
      const newFormData = updateFormDataForStep({
        forms: state.forms,
        step: payload?.step,
        data: payload?.data,
        stepKey: payload?.stepKey,
      });
      return {
        ...state,
        forms: newFormData,
      };
    }
    case "UPDATE_CURRENT_FORM": {
      const { payload } = action;
      return {
        ...state,
        currentForm: { [payload?.stepKey as string]: payload?.data },
      };
    }
    case "UPDATE_STEP": {
      const { payload } = action;
      return {
        ...state,
        currentStep: payload?.step || 0,
      };
    }
    default:
      return state;
  }
};

export const SteppedFormContext = createContext<FormContextType>({
  state: initialState,
  dispatch: () => {},
  stepInfo: null,
  handleMoveForward: () => {},
});

const SteppedForm = ({ steps }: SteppedFormType): JSX.Element => {
  const navigate = useNavigate();
  const location = useLocation();
  const [state, dispatch] = useReducer(reducer, initialState);
  const { currentStep, currentForm, forms } = state;
  const [searchParams, setSearchParams] = useSearchParams();
  const step = searchParams.get("step");
  const stepInfo = steps[state.currentStep];

  useEffect(() => {
    if (!step || forms.length === 0) {
      const params = {
        step: "0",
      };

      setSearchParams(params, { replace: true });
    }
  }, []);

  useEffect(() => {
    if (step) {
      dispatch({
        type: "UPDATE_STEP",
        payload: {
          step: parseInt(step),
        },
      });
    }
  }, [step]);

  const handleMoveForward = (stepKey: string) => {
    const currentFormData = currentForm;
    let isValidated = true;

    if (stepInfo?.beforeNextStep) {
      isValidated = stepInfo.beforeNextStep();
    }

    if (!isValidated) return;

    dispatch({
      type: "UPDATE_FORM",
      payload: {
        step: currentStep,
        data: currentFormData,
        stepKey,
      },
    });

    dispatch({
      type: "UPDATE_CURRENT_FORM",
      payload: {
        data: null,
      },
    });

    navigate({
      pathname: location.pathname,
      search: createSearchParams({
        step: `${currentStep + 1}`,
      }).toString(),
    });
  };

  return (
    <SteppedFormContext.Provider
      value={{ state, stepInfo, dispatch, handleMoveForward }}
    >
      <Box width="100%">
        <Box
          width="100%"
          borderBottomWidth="thin"
          marginBottom="20px"
          padding="20px"
          display="flex"
          justifyContent="center"
        >
          <Box
            display="flex"
            justifyContent="space-between"
            alignItems="center"
            maxWidth="1300px"
            width="100%"
          >
            <Box>
              <Text fontSize="l" color="gray">
                STEP {currentStep + 1} OF {steps.length}
              </Text>
              <Text fontWeight="bold" fontSize="xl">
                {stepInfo.name}
              </Text>
            </Box>
            <Box>
              <ExitModal />
            </Box>
          </Box>
        </Box>
        {stepInfo.component}
        {stepInfo.isRequireContinueCta ? (
          <Box padding="10px" display="flex" justifyContent="center">
            <Box maxWidth="1300px" width="100%">
              <Button onClick={() => handleMoveForward(stepInfo.formKey)}>
                Continue
              </Button>
            </Box>
          </Box>
        ) : null}
      </Box>
    </SteppedFormContext.Provider>
  );
};

export default SteppedForm;
