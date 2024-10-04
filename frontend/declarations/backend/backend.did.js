export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'getExampleNames' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getShaderCode' : IDL.Func([IDL.Text], [IDL.Opt(IDL.Text)], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
