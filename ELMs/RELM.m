% RELM - Regularized Extreme Learning Machine Class
%   Train and Predict a SLFN based on Regularized Extreme Learning Machine
%
%   This code was implemented based on the following paper:
%
%   [1] Guang-Bin Huang, Hongming Zhou, Xiaojian Ding, and Rui Zhang, Extreme
%       Learning Machine for Regression and Multiclass Classification.
%       Trans. Sys. Man Cyber. Part B 42, 2 (April 2012), 513-529.
%       http://dx.doi.org/10.1109/TSMCB.2011.2168604
%       (http://ieeexplore.ieee.org/document/6035797/)
%
%   [2] José M. Martínez-Martínez, Pablo Escandell-Montero, Emilio Soria-Olivas,
%       José D. Martín-Guerrero, Rafael Magdalena-Benedito, Juan Gómez-Sanchis,
%       Regularized extreme learning machine for regression problems,
%       Neurocomputing, Volume 74, Issue 17, 2011, Pages 3716-3721, ISSN 0925-2312,
%       https://doi.org/10.1016/j.neucom.2011.06.013.
%       (http://www.sciencedirect.com/science/article/pii/S092523121100378X)
%
%   Attributes:
%       Attributes between *.* must be informed.
%       R-ELM objects must be created using name-value pair arguments (see the Usage Example).
%
%         *numberOfInputNeurons*:   Number of neurons in the input layer.
%                Accepted Values:   Any positive integer.
%
%          numberOfHiddenNeurons:   Number of neurons in the hidden layer
%                Accepted Values:   Any positive integer (defaut = 1000).
%
%       regularizationParameter:   Regularization Parameter (defaut = 1000)
%                Accepted Values:   Any positive real number.
%
%                          alpha:   Regularization Parameter (defaut = 0)
%                Accepted Values:   Any positive real number between [0,1].
%                                   0: ridge | 1: lasso | (0,1): elastic net
%
%             activationFunction:   Activation funcion for hidden layer
%                Accepted Values:   Function handle (see [1]) or one of these strings:
%                                       'sig':     Sigmoid (default)
%                                       'sin':     Sine
%                                       'hardlim': Hard Limit
%                                       'tribas':  Triangular basis function
%                                       'radbas':  Radial basis function
%
%                           seed:   Seed to generate the pseudo-random values.
%                                   This attribute is for reproducible research.
%                Accepted Values:   RandStream object or a integer seed for RandStream.
%
%       Attributes generated by the code:
%
%                    inputWeight:   Weight matrix that connects the input
%                                   layer to the hidden layer
%
%            biasOfHiddenNeurons:   Bias of hidden units
%
%                   outputWeight:   Weight matrix that connects the hidden
%                                   layer to the output layer
%
%                      intercept:   Intercept value (beta_0) for alpha in
%                                   (0,1]
%
%   Methods:
%
%       obj = RELM(varargin):        Creates RELM objects. varargin should be in
%                                    pairs. Look attributes
%
%       obj = obj.train(X,Y):        Method for training. X is the input of size N x n,
%                                    where N is (# of samples) and n is the (# of features).
%                                    Y is the output of size N x m, where m is (# of multiple outputs)
%
%       Yhat = obj.predict(X):       Predicts the output for X.
%
%   Usage Example:
%
%       load iris_dataset.mat
%       X    = irisInputs';
%       Y    = irisTargets';
%       % ridge
%       relm  = RELM('numberOfInputNeurons', 4, 'numberOfHiddenNeurons',100);
%       relm  = relm.train(X, Y);
%       Yhat = relm.predict(X)
%       % lasso
%       relm  = RELM('numberOfInputNeurons', 4, 'numberOfHiddenNeurons',100, 'alpha', 1);
%       relm  = relm.train(X, Y);
%       Yhat = relm.predict(X)

%   License:
%
%   Permission to use, copy, or modify this software and its documentation
%   for educational and research purposes only and without fee is here
%   granted, provided that this copyright notice and the original authors'
%   names appear on all copies and supporting documentation. This program
%   shall not be used, rewritten, or adapted as the basis of a commercial
%   software or hardware product without first obtaining permission of the
%   authors. The authors make no representations about the suitability of
%   this software for any purpose. It is provided "as is" without express
%   or implied warranty.
%
%       Federal University of Espirito Santo (UFES), Brazil
%       Computers and Neural Systems Lab. (LabCISNE)
%       Authors:    F. K. Inaba, B. L. S. Silva, D. L. Cosmo
%       email:      labcisne@gmail.com
%       website:    github.com/labcisne/ELMToolbox
%       date:       Jan/2018

classdef RELM < ELM
    properties
        regularizationParameter = 1000
        alpha = 0;
        intercept = 0
    end
    methods
        function self = RELM(varargin)
            self = self@ELM(varargin{:});
        end
        
        function self = train(self, X, Y)
            auxTime = toc;
            tempH = X*self.inputWeight + repmat(self.biasOfHiddenNeurons,size(X,1),1);
            H = self.activationFunction(tempH);
            clear tempH;
            if (self.alpha == 0)
                if size(H,1)>=size(H,2)
                    self.outputWeight = (eye(size(H,2))/self.regularizationParameter + H' * H) \ H' * Y;
                else
                    self.outputWeight = H' * ((eye(size(H,1))/self.regularizationParameter + H * H') \ Y);
                end
            else
                self.outputWeight = zeros(self.numberOfHiddenNeurons, size(Y,2));
                self.intercept = zeros(1,size(Y,2));
                for j=1:size(Y,2)
                    [self.outputWeight(:,j), tmp] = lasso(H, Y(:,j), 'alpha', self.alpha, 'Lambda', 1/self.regularizationParameter);
                    self.intercept(1,j) = tmp.Intercept;
                end
            end
            self.trainTime = toc - auxTime;
        end
        function Yhat = predict(self, X)
            auxTime = toc;
            tempH = X*self.inputWeight + repmat(self.biasOfHiddenNeurons,size(X,1),1);
            H = self.activationFunction(tempH);
            clear tempH;
            if (self.alpha == 0)
                Yhat = H * self.outputWeight;
            else
                Yhat = H * self.outputWeight + repmat(self.intercept,size(H,1),1);
            end
            self.lastTestTime = toc - auxTime;
        end
    end
end
