import {Amplify, Auth} from "aws-amplify";
import React, { useEffect } from "react";
import {useSelector} from "react-redux";
import {useHistory} from "react-router-dom";
import {ReduxRoot} from "../../interfaces";

function Cognito (props: any) {

  const history = useHistory();

  const amplifyConfig = {
    Auth: {
      mandatorySignIn: true,
      region: 'us-east-1',
      userPoolId: '###SSM_USER_POOL_ID###',
      identityPoolId: '###SSM_IDENTITY_POOL_ID###',
      userPoolWebClientId: '###SSM_WEB_CLIENT_ID###',
      oauth: {
        domain: '###APP_NAME###-###ENV_NAME###.auth.###AWS_DEFAULT_REGION###.amazoncognito.com',
        redirectSignIn: 'https://###SSM_CLOUDFRONT_DOMAIN###/',
        redirectSignOut: 'https://###SSM_CLOUDFRONT_DOMAIN###/',
        responseType: 'code' // or 'token', note that REFRESH token will only be generated when the responseType is code
      }
    }
  };

  Amplify.configure(amplifyConfig);
  Auth.configure(amplifyConfig);

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  useEffect(() => {

    if (token === "") {
      history.push("/Login");
    }

  }, [history, token]);

  return (
      <div />
  );
}

export default Cognito;