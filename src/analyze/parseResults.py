#! /usr/bin/python

import argparse
import csv
import re
from os import path


def parseDurationOrFloat(durationStr):
    
    parts = re.split('(\d+[,\.]?\d*)', durationStr)
    parts = [p for p in parts if p and len(p) > 0]
    
    try:
        if len(parts) >= 2:
            if parts[1] == "ns":
                return float(parts[0]) * 10e-9 
            if parts[1] == "us":
                return float(parts[0]) * 10e-6
            if parts[1] == "ms":
                return float(parts[0]) * 10e-3
            if parts[1] == "s":
                return float(parts[0])
            if parts[1] == "min":
                return float(parts[0]) * 60
            if parts[1] == "h":
                return float(parts[0]) * 60 * 60
            if parts[1] == "d":
                return float(parts[0]) * 60 * 60 * 24
        
        # if its no time return simple float
        return float(durationStr)
        
    except:
        # if parsing fails return string
        return durationStr

class ResultAnalyzer():
    def __init__(self, rowDelim = ' ', timeIdx = 0, configIdx = 2, performanceIdx = 3, correction=1.0, correctionIdx=1):
        self.rowDelim = rowDelim
        self.timeIdx = timeIdx
        self.configIdx = configIdx
        self.performanceIdx = performanceIdx
        self.correction = correction
        self.correctionIdx = correctionIdx
        
    
    def analyzeFile(self, fileName):
        with open(fileName) as results:
            
            csvReader = csv.reader(results, delimiter=self.rowDelim)
            
            # skip header
            next(csvReader)
            
            results = {}
            # read all rows
            for row in csvReader:
                time = parseDurationOrFloat(row[self.timeIdx])
                
                # get performance value
                performanceValue = parseDurationOrFloat(row[self.performanceIdx])
                
                if len(str(performanceValue)) > 0 and len(str(time)) > 0:
                    # write results to dict
                    
                    if not row[self.configIdx] in results.keys():
                        results[row[self.configIdx]] = []
                    results[row[self.configIdx]].append([time, performanceValue])
            
        # apply correction factor
        for i in range(0, len(results[results.keys()[self.correctionIdx]])):
            results[results.keys()[self.correctionIdx]][i][1] *= self.correction
            
        return results
        
    def writeOutput(self, fileName, valuesList, headerNames):
        with open(fileName, 'w') as out:
            csvWriter = csv.writer(out, delimiter=self.rowDelim)
            # write header
            csvWriter.writerow(headerNames)
            
            for values in valuesList:
                csvWriter.writerow(values)
    
    def calcResults(self, values0, values1):
        result = []
        
        resultList = {}
        for val in values0:
            resultList[val[0]] = [val[1]]
        for val in values1:
            if val[0] in resultList.keys():
                resultList[val[0]].append(val[1])
        
        resultList = [(k,v) for k,v in resultList.iteritems() if len(v) > 1]
        
        for k, val in resultList:
            result.append((k, val[0] - val[1], val[0]/val[1]))
        
        # print average results
        print("The average difference is: %f" % (sum([val[1] for val in result]) / len(result)))
        print("The average ratio is: %f" % (sum([val[2] for val in result]) / len(result)))
        return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Script for analyzing generated result files and convert times")
    parser.add_argument("fileName", help="filename of results file")
    parser.add_argument("-o", "--output-dir", dest="output", help="directory for generated output files")
    parser.add_argument("-g", "--generate-results", dest="results", action="store_true", help="flag for generating the results file (ratio and diff) only for 2 configurations")
    parser.add_argument("-i", "--performance-index", dest="index", type=int, help="Index of performance value within row of results file")
    parser.add_argument("-t", "--time-index", dest="timeIdx", type=int, help="Index of time value within row of results file")
    parser.add_argument("-c", "--config-index", dest="config", type=int, help="Index of configuration within row of results file")
    parser.add_argument("-f", "--correction-factor", dest="correction", type=float, help="Correction value for the performance value of the second configuration")
    args = parser.parse_args()
    
    print("started")
    
    print(args)
    
    fileName = args.fileName
    #fileName= "results.txt"
    
    parts = fileName.split('.')
    filePrefix = '.'.join(parts[:-1])
    fileExt = parts[-1]
    fileBasename = path.splitext(path.basename(fileName))[0]
    
    # check parameter
    
    if args.correction != None:
        corr = args.correction
    else:
        corr = 1.0
    
    if args.index != None:
        idx = args.index
    else:
        idx = 5
    
    if args.timeIdx != None:
        timeIdx = args.timeIdx
    else:
        timeIdx = 1
        
    if args.config != None:
        configIdx = args.config
    else:
        configIdx = 2
    
    analyzer = ResultAnalyzer(performanceIdx=idx, correction=corr, timeIdx=timeIdx, configIdx=configIdx)
    
    results = analyzer.analyzeFile(fileName)
    
    print("analyzed configurations:")
    for key in results.keys():
        print("   %s: %d entries" % (key, len(results[key])))
    
    for key in results.keys():
        if args.output:
            resultFile = args.output + path.sep + fileBasename + '.'  + key + '.' + fileExt
        else:
            resultFile = filePrefix + '.'  + key + '.' + fileExt
        analyzer.writeOutput(resultFile, results[key], ("Time", "PerformanceValue"))
        
    if args.results:
        if not len(results) == 2:
            raise "Results calculation is only possible for 2 configurations"
        
        print("generate results file")
        if args.output:
            resultFile = args.output + path.sep + fileBasename + '.results.' + fileExt
        else:
            resultFile = filePrefix + '.results.' + fileExt
        
        # calculate difference and ratio of performance values
        result = analyzer.calcResults(results.values()[0], results.values()[1])
        
        analyzer.writeOutput(resultFile, result, ("Time", "Difference", "Ratio"))
    
    print("finished")
    
    
    
    
    
    
